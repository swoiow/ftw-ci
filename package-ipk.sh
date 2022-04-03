BIN_DIR=tmp/go-net
BIN_DIR_WITH_SLASH=/$BIN_DIR
TODAY=$(date +%Y%m%d)

# clean up
rm -rf control data *.ipk

# make control
mkdir "control"
cat>control/control<<EOF
Package: go-net
Version: $TODAY
Section: net
Priority: optional
Architecture: all
Maintainer:null
Description: null
EOF
## before install
cat>control/preinst<<EOF
#!/bin/sh
mkdir -p /tmp/update-net
mv $BIN_DIR_WITH_SLASH/*.json /tmp/update-net
rm -rf $BIN_DIR_WITH_SLASH
echo "preinst done" > /tmp/net.log
EOF
## after install
cat>control/postinst<<EOF
#!/bin/sh
chmod 744 $BIN_DIR_WITH_SLASH/net $BIN_DIR_WITH_SLASH/geo*.dat
chown root:root $BIN_DIR_WITH_SLASH/net $BIN_DIR_WITH_SLASH/geo*.dat
ln -s $BIN_DIR_WITH_SLASH/net /usr/bin/go-net

echo "#!/bin/sh" > /tmp/run-net.sh
echo "export V2RAY_CONF_GEOLOADER=memconservative" >> /tmp/run-net.sh
echo "export V2RAY_LOCATION_CONFIG=$BIN_DIR_WITH_SLASH" >> /tmp/run-net.sh
echo "export V2RAY_LOCATION_ASSET=$BIN_DIR_WITH_SLASH" >> /tmp/run-net.sh
echo "go-net" >> /tmp/run-net.sh

[ -f /tmp/update-net/*.json ] && mv /tmp/update-net/*.json $BIN_DIR_WITH_SLASH
rm -rf /tmp/update-net

echo "postinst done" >> /tmp/net.log
EOF
# after remove
cat>control/postrm<<EOF
#!/bin/sh
rm /usr/bin/go-net
echo "postrm done" >> /tmp/net.log
EOF
cd control
chmod +x *
tar -czf control.tar.gz *
cd ..

# make data
mkdir "data"
cp net data
cd data
mkdir -p $BIN_DIR
mv net $BIN_DIR
wget https://github.com/Loyalsoldier/v2ray-rules-dat/releases/latest/download/geosite.dat -O geosite.dat
wget https://raw.githubusercontent.com/Loyalsoldier/geoip/release/geoip-only-cn-private.dat -O geoip.dat
mv *.dat $BIN_DIR
chmod +x -R ../data
tar -czf data.tar.gz *
cd ..

# pack it
mv control/*.tar.gz .
mv data/*.tar.gz .
tar -czf net.ipk *.tar.gz

# clean up
rm -rf control* data*
