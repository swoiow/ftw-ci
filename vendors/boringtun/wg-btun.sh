#!/bin/bash
# ----------------------------------------------------------------
# Design Intent: Self-installing WireGuard Manager for BoringTun
# Architecture: User-space driver with defensive spin-locks
# Version: 1.2.0 (Zero Hard-coding Refactor)
# ----------------------------------------------------------------

set -e

# --- Configuration (Defaults & Paths) ---
INTERFACE="wg0"
CONF_FILE="/etc/wireguard/${INTERFACE}.conf"
BIN_BORING="/usr/bin/boringtun-cli"
LOG_FILE="/var/log/wg-boring.log"

# Default Network Values
DEFAULT_ADDR="10.6.0.1/24"
DEFAULT_MTU="1420"

# Service & Path discovery
SERVICE_NAME="wg-btun"
SCRIPT_PATH=$(realpath "$0")

# --- Logging Engine ---
log() {
    local level="$1"
    local msg="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local formatted_msg="[$timestamp] [$level] $msg"

    echo "$formatted_msg"
    echo "$formatted_msg" >> "$LOG_FILE"
}

# --- Feature: Environmental Audit ---
debug_env() {
    log "DEBUG" "=== Environmental Audit Starting ==="
    log "DEBUG" "Kernel: $(uname -a)"
    log "DEBUG" "Binary Version: $($BIN_BORING --version 2>&1 || echo 'unknown')"
    log "DEBUG" "TUN Device: $(ls -l /dev/net/tun 2>/dev/null || echo 'NOT FOUND')"
    log "DEBUG" "Default Fallbacks: Addr=$DEFAULT_ADDR, MTU=$DEFAULT_MTU"
    log "DEBUG" "=== Environmental Audit Complete ==="
}

# --- Feature: Auto Setup (IaC) ---
setup_service() {
    log "INFO" "Installing $SERVICE_NAME systemd service..."

    if [[ $EUID -ne 0 ]]; then
       log "ERROR" "Setup must be run as root."
       exit 1
    fi

    cat <<EOF > /etc/systemd/system/${SERVICE_NAME}.service
[Unit]
Description=WireGuard User-space Service (BoringTun)
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=${SCRIPT_PATH} up
ExecStop=${SCRIPT_PATH} down
StandardOutput=append:${LOG_FILE}
StandardError=append:${LOG_FILE}

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reload
    systemctl enable ${SERVICE_NAME}.service
    log "INFO" "Service enabled at /etc/systemd/system/${SERVICE_NAME}.service"
}

case "$1" in
    up)
        log "INFO" ">>> Initiating Activation Flow for $INTERFACE <<<"

        # 1. 环境预检
        if [ ! -c /dev/net/tun ]; then
            log "WARN" "/dev/net/tun missing, creating node..."
            mkdir -p /dev/net && mknod /dev/net/tun c 10 200 && chmod 666 /dev/net/tun
        fi

        # 2. 启动守护进程
        export WG_LOG_LEVEL=debug
        export WG_THREADS=2
        debug_env

        log "INFO" "Launching BoringTun..."
        $BIN_BORING --disable-drop-privileges "$INTERFACE" >> "$LOG_FILE" 2>&1

        # 3. 阻塞式自旋锁
        timeout=10
        while [ $timeout -gt 0 ]; do
            if [ -d "/sys/class/net/$INTERFACE" ] && wg show "$INTERFACE" >/dev/null 2>&1; then break; fi
            sleep 1; ((timeout--))
        done

        if [ $timeout -le 0 ]; then
            log "ERROR" "Interface $INTERFACE failed to stabilize."; exit 1
        fi

        # 4. 配置注入
        log "INFO" "Filtering and Injecting configuration..."
        CLEAN_CONF=$(sed '/^Address/d; /^DNS/d; /^MTU/d; /^PostUp/d; /^PostDown/d; /^SaveConfig/d' "$CONF_FILE")

        if ! echo "$CLEAN_CONF" | wg setconf "$INTERFACE" /dev/stdin 2>>"$LOG_FILE"; then
            log "ERROR" "Configuration injection failed."; exit 1
        fi

        # 5. 网络层部署 (Using Default Variables)
        # 尝试从配置文件抓取，抓不到则使用 DEFAULT_ADDR
        ADDR_FROM_CONF=$(grep '^Address' "$CONF_FILE" | awk -F '[ =]+' '{print $2}' | head -n 1)
        FINAL_ADDR="${ADDR_FROM_CONF:-$DEFAULT_ADDR}"

        # 尝试抓取 MTU，抓不到则使用 DEFAULT_MTU
        MTU_FROM_CONF=$(grep '^MTU' "$CONF_FILE" | awk -F '[ =]+' '{print $2}' | head -n 1)
        FINAL_MTU="${MTU_FROM_CONF:-$DEFAULT_MTU}"

        log "INFO" "Applying IP: $FINAL_ADDR, MTU: $FINAL_MTU"

        if ! ip addr show "$INTERFACE" | grep -q "${FINAL_ADDR%/*}"; then
            ip address add "$FINAL_ADDR" dev "$INTERFACE"
        fi
        ip link set mtu "$FINAL_MTU" up dev "$INTERFACE"

        # 处理 PostUp
        POST_UP=$(grep '^PostUp' "$CONF_FILE" | cut -d '=' -f 2-)
        [ -n "$POST_UP" ] && eval "$POST_UP" >> "$LOG_FILE" 2>&1

        log "INFO" ">>> $INTERFACE activated <<<"
        ;;

    down)
        log "INFO" ">>> Deactivating $INTERFACE <<<"
        POST_DOWN=$(grep '^PostDown' "$CONF_FILE" | cut -d '=' -f 2-)
        [ -n "$POST_DOWN" ] && eval "$POST_DOWN" >> "$LOG_FILE" 2>&1

        [ -d "/sys/class/net/$INTERFACE" ] && ip link delete "$INTERFACE"
        log "INFO" ">>> Service stopped <<<"
        ;;

    setup)
        setup_service
        ;;

    *)
        echo "Usage: $0 {up|down|setup}"
        exit 1
        ;;
esac