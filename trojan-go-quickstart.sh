#!/bin/sh
echo "Getting the latest version of trojan-go"
NAME=trojan-go
VERSION="$(wget --no-check-certificate -qO- https://api.github.com/repos/p4gefau1t/trojan-go/tags | grep 'name' | cut -d\" -f4 | head -1)"
echo "${VERSION}"
TARBALL="trojan-go-linux-amd64.zip"
DOWNLOADURL="https://github.com/p4gefau1t/trojan-go/releases/download/${VERSION}/$TARBALL"
TMPDIR="$(mktemp -d)"
INSTALLPREFIX=/usr
SYSTEMDPREFIX=/etc/systemd/system
BINARYPATH="$INSTALLPREFIX/bin/$NAME"
CONFIGPATH="/etc/$NAME"
SYSTEMDPATH="$SYSTEMDPREFIX/$NAME.service"
mkdir -p "$INSTALLPREFIX/bin"
mkdir -p "$CONFIGPATH"

echo Entering temp directory $TMPDIR...
cd "$TMPDIR"

echo Downloading $NAME $VERSION...
curl -LO --progress-bar "$DOWNLOADURL" || wget -q --show-progress "$DOWNLOADURL"

echo Unpacking $NAME $VERSION...
unzip -q "$TARBALL" && rm -rf "$TARBALL"

echo Installing $NAME $VERSION to $BINARYPATH...

mv "$NAME" $BINARYPATH && chmod +x $BINARYPATH
mv geoip.dat "$CONFIGPATH/geoip.dat"
mv geosite.dat "$CONFIGPATH/geosite.dat"
mv example/trojan-go.service "$SYSTEMDPATH"

# if config.json didn't exist, use the example server.json
if [ ! -f "$CONFIGPATH/config.json" ]; then
  mv example/server.json $CONFIGPATH/config.json
fi

systemctl daemon-reload
systemctl reset-failed

echo "trojan-go is installed."
