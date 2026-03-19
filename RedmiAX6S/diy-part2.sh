#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# 修改默认IP & 固件名称 & 编译署名和时间
sed -i 's/192.168.1.1/10.0.0.1/g' package/base-files/files/bin/config_generate
sed -i "s/hostname='.*'/hostname='RedmiAX6S'/g" package/base-files/files/bin/config_generate
sed -i "s#_('Firmware Version'), (L\.isObject(boardinfo\.release) ? boardinfo\.release\.description + ' / ' : '') + (luciversion || ''),# \
            _('Firmware Version'),\n \
            E('span', {}, [\n \
                (L.isObject(boardinfo.release)\n \
                ? boardinfo.release.description + ' / '\n \
                : '') + (luciversion || '') + ' / ',\n \
            E('a', {\n \
                href: 'https://github.com/dolphin738/Actions-openwrt/releases',\n \
                target: '_blank',\n \
                rel: 'noopener noreferrer'\n \
                }, [ 'Built by dolphin738 $(date "+%Y-%m-%d %H:%M:%S")' ])\n \
            ]),#" feeds/luci/modules/luci-mod-status/htdocs/luci-static/resources/view/status/include/10_system.js
            
# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 更改默认 Shell 为 zsh
#sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# 移除要替换的包
#rm -rf feeds/luci/themes/luci-theme-argon
#rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/packages/net/onionshare-cli
rm -rf feeds/luci/applications/luci-app-appfilter
rm -rf feeds/packages/net/open-app-filter
rm -rf feeds/packages/net/{xray-core,v2ray-geodata,sing-box,chinadns-ng,dns2socks,hysteria,ipt2socks,microsocks,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,tcping,trojan-plus,tuic-client,v2ray-plugin,xray-plugin,geoview,shadow-tls}
rm -rf feeds/luci/applications/luci-app-passwall

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# # 添加额外插件
git clone --depth=1 https://github.com/stackia/rtp2httpd package/rtp2httpd
git_sparse_clone main https://github.com/dolphin738/op-packages luci-app-wrtbwmon  wrtbwmon
git_sparse_clone main https://github.com/dolphin738/op-packages luci-app-netspeedtest homebox ookla-speedtest
git_sparse_clone main https://github.com/dolphin738/op-packages luci-app-turboacc shortcut-fe
git_sparse_clone main https://github.com/dolphin738/op-packages luci-app-easytier easytier
git_sparse_clone main https://github.com/dolphin738/op-packages luci-app-taskplan
git_sparse_clone main https://github.com/dolphin738/op-packages luci-app-timedreboot
git_sparse_clone main https://github.com/dolphin738/op-packages file
mv -f package/files files && rm  -rf files/opkg
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/passwall-packages
git_sparse_clone main https://github.com/Openwrt-Passwall/openwrt-passwall luci-app-passwall

# # 修改默认设置
#git_sparse_clone main https://github.com/dolphin738/op-packages files
#mv -f package/files ./ && rm -rf files/etc/opkg/customfeeds.conf
sed -i 's|opkg_mirror="https://mirrors.vsean.net/openwrt"|opkg_mirror="https://mirrors.pku.edu.cn/immortalwrt"|g' package/emortal/default-settings/files/99-default-settings-chinese
#sed -i 's|zram_comp_algo="lzo"|zram_comp_algo="zstd"|g' package/system/zram-swap/files/zram.init
#sed -i 's|bootstrap|kucat|g' feeds/luci/modules/luci-base/root/etc/config/luci

# 安装主题
#git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon feeds/luci/themes/luci-theme-argon
#git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config feeds/luci/applications/luci-app-argon-config
#git clone --depth=1 https://github.com/eamonxg/luci-theme-aurora feeds/luci/themes/luci-theme-aurora
#git clone --depth=1 https://github.com/eamonxg/luci-app-aurora-config feeds/luci/applications/luci-app-aurora-config
#git clone --depth=1 https://github.com/papagaye744/luci-theme-design.git package/luci-theme-design
#git clone --depth=1 https://github.com/gngpp/luci-app-design-config.git package/luci-app-design-config
git clone --depth=1 https://github.com/sirpdboy/luci-theme-kucat.git package/luci-theme-kucat
git clone --depth=1 https://github.com/sirpdboy/luci-app-kucat-config.git package/luci-app-kucat-config
git clone --depth=1 https://github.com/derisamedia/luci-theme-alpha-reborn.git package/luci-theme-4lpha

# 清理所有临时缓存和索引 (让系统自动重建，而不是手动删行)
# 这会清除所有 feeds 的 .tmp 目录，强制系统在下次 update 时重新扫描
# 如果有其他自定义 feed，也建议清理对应的 .tmp 目录
rm -rf feeds/luci.tmp
rm -rf feeds/packages.tmp
# rm -rf feeds/base.tmp

./scripts/feeds update -a
./scripts/feeds install -a
