#!/bin/sh
set -e

# 打印变量供调试
echo "UPDATE_ASSETS=${UPDATE_ASSETS}"
echo "ASSETS_PATH=${ASSETS_PATH}"
echo "GEOIP_URL=${GEOIP_URL}"
echo "GEOLITE2_URL=${GEOLITE2_URL}"

# 如果需要更新资源
if [ "$UPDATE_ASSETS" = "1" ]; then
  echo "[INFO] Updating assets..."
  mkdir -p "${ASSETS_PATH}"
  curl -fsSL -o "${ASSETS_PATH}/geoip.dat" "$GEOIP_URL"
  curl -fsSL -o "${ASSETS_PATH}/GeoLite2-Country.mmdb" "$GEOLITE2_URL"
fi

# 判断是否存在 tini
if [ -x "/usr/local/bin/tini" ]; then
  echo "[INFO] Starting with tini..."
  exec /usr/local/bin/tini -- hysteria "$@"
else
  echo "[WARN] Tini not found. Starting directly..."
  exec hysteria "$@"
fi
