#!/bin/bash
# AutoBuild Module by Hyy2001 <https://github.com/Hyy2001X/AutoBuild-Actions-BETA>
# AutoBuild DiyScript


echo "开始 DIY 配置..."
echo "===================="

# Git稀疏克隆，只克隆指定目录到本地
# 参数1是分支名, 参数2是仓库地址, 参数3是子目录，同一个仓库下载多个文件夹直接在后面跟文件名或路径，空格分开
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 添加自定义软件包
echo '
CONFIG_PACKAGE_luci-app-passwall=y         #passwall
CONFIG_PACKAGE_luci-app-ttyd=y             #ttyd
CONFIG_PACKAGE_luci-app-adguardhome=y      #adguardhome
CONFIG_PACKAGE_luci-app-openclash=y        #openclash
' >> .config

# git clone https://github.com/Openwrt-Passwall/openwrt-passwall package/passwall
# git clone https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/openwrt-passwall-packages
# git clone https://github.com/AdguardTeam/AdGuardHome package/AdGuardHome
# git clone https://github.com/vernesong/OpenClash package/OpenClash




echo 'zzz-default-settings自定义'
# 网络配置信息，将从 zzz-default-settings 文件的第2行开始添加 
# 参考 https://github.com/coolsnowwolf/lede/blob/master/package/lean/default-settings/files/zzz-default-settings
# 先替换掉最后一行 exit 0 再追加自定义内容
sed -i '/.*exit 0*/c\# 自定义配置' package/emortal/default-settings/files/99-default-settings
cat >> package/emortal/default-settings/files/99-default-settings <<-EOF

uci add_list network.lan.dns='223.5.5.5'
uci set network.lan.gateway='192.168.9.1'
uci commit network







exit 0
EOF









./scripts/feeds update -a
./scripts/feeds install -a

#内置X86-clash内核
mkdir -p files/etc/openclash/core
wget -qO- https://github.com/vernesong/OpenClash/raw/core/master/meta/clash-linux-amd64.tar.gz | tar xOvz > files/etc/openclash/core/clash_meta
chmod +x files/etc/openclash/core/clash*

#将AdGuardHome核心文件编译进目录
curl -s https://api.github.com/repos/AdguardTeam/AdGuardHome/releases/latest \
| grep "browser_download_url.*AdGuardHome_linux_amd64.tar.gz" \
| cut -d : -f 2,3 \
| tr -d \" \
| xargs curl -L -o /tmp/AdGuardHome_linux_amd64.tar.gz && \
tar -xzvf /tmp/AdGuardHome_linux_amd64.tar.gz -C /tmp/ --strip-components=1 && \
mkdir -p files/usr/bin/AdGuardHome && \
mv /tmp/AdGuardHome/AdGuardHome files/usr/bin/AdGuardHome/
chmod 0777 files/usr/bin/AdGuardHome/AdGuardHome

echo "===================="
echo "结束 DIY 配置..."





















