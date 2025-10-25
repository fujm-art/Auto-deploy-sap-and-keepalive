#!/usr/bin/env sh

XRAY_VERSION="${XRAY_VERSION:-25.10.15}"
ARGO_VERSION="${ARGO_VERSION:-2025.10.0}"
DOMAIN="${DOMAIN:-vevc.github.com}"
PORT="${PORT:-10008}"
UUID="${UUID:-$(cat /proc/sys/kernel/random/uuid)}"
ARGO_DOMAIN="${ARGO_DOMAIN:-xxx.trycloudflare.com}"
ARGO_TOKEN="${ARGO_TOKEN:-}"
REMARKS_PREFIX="${REMARKS_PREFIX:-vevc}"
MAIN_FILE="${MAIN_FILE:-$(openssl rand -hex 8).js}"

sys_arch=amd64
xray_arch=64
arch=$(uname -m)
case "$arch" in
  arm*|aarch64)
    sys_arch=arm64
    xray_arch=arm64-v8a
    ;;
esac

curl -sSL -o "$MAIN_FILE" https://raw.githubusercontent.com/vevc/node-xah/refs/heads/main/index.js
curl -sSL -o package.json https://raw.githubusercontent.com/vevc/node-xah/refs/heads/main/package.json
sed -i "s/index.js/$MAIN_FILE/g" package.json

mkdir -p /home/container/cf
cd /home/container/cf
random_cf_name=$(openssl rand -hex 8)
curl -sSL -o "$random_cf_name" https://github.com/cloudflare/cloudflared/releases/download/$ARGO_VERSION/cloudflared-linux-$sys_arch
chmod +x "$random_cf_name"

mkdir -p /home/container/xy
cd /home/container/xy
rm -f *
random_xray_zip=$(openssl rand -hex 8).zip
curl -sSL -o "$random_xray_zip" https://github.com/XTLS/Xray-core/releases/download/v$XRAY_VERSION/Xray-linux-$xray_arch.zip
unzip "$random_xray_zip"
rm "$random_xray_zip"
random_xray_bin=$(openssl rand -hex 8)
mv xray "$random_xray_bin"
random_config=$(openssl rand -hex 8).json
curl -sSL -o "$random_config" https://raw.githubusercontent.com/vevc/node-xah/refs/heads/main/xray-config.json
sed -i "s/10008/$PORT/g" "$random_config"
sed -i "s/YOUR_UUID/$UUID/g" "$random_config"
wsUrl="vless://$UUID@$ARGO_DOMAIN:443?encryption=none&security=tls&fp=chrome&type=ws&path=%2F%3Fed%3D2560#$REMARKS_PREFIX-ws-argo"
echo "$wsUrl" > /home/container/12.txt

cd /home/container
sed -i "s/YOUR_DOMAIN/$DOMAIN/g" "$MAIN_FILE"
sed -i "s/10008/$PORT/g" "$MAIN_FILE"
sed -i "s/YOUR_UUID/$UUID/g" "$MAIN_FILE"
sed -i "s/YOUR_ARGO_DOMAIN/$ARGO_DOMAIN/g" "$MAIN_FILE"
sed -i 's/ARGO_TOKEN = ""/ARGO_TOKEN = "'$ARGO_TOKEN'"/g' "$MAIN_FILE"
sed -i "s/YOUR_REMARKS_PREFIX/$REMARKS_PREFIX/g" "$MAIN_FILE"

echo "Installation completed. Restart the server and enjoy"