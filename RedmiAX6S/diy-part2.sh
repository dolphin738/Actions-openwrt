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
#sed -i 's/192.168.1.1/192.168.2.254/g' package/base-files/files/bin/config_generate
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
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
rm -rf feeds/packages/net/onionshare-cli
rm -rf feeds/luci/applications/luci-app-appfilter
rm -rf feeds/packages/net/open-app-filter

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
#git_sparse_clone main https://github.com/kiddin9/op-packages luci-app-adguardhome
#git_sparse_clone main https://github.com/kiddin9/op-packages luci-app-wrtbwmon  wrtbwmon
#git_sparse_clone main https://github.com/kiddin9/op-packages luci-app-netspeedtest
#git_sparse_clone main https://github.com/kiddin9/op-packages homebox
#git_sparse_clone main https://github.com/kiddin9/op-packages ookla-speedtest
#git_sparse_clone main https://github.com/kiddin9/op-packages luci-app-turboacc
#git_sparse_clone main https://github.com/kiddin9/op-packages shortcut-fe
#git_sparse_clone main https://github.com/kiddin9/op-packages luci-app-easytier easytier
#git_sparse_clone main https://github.com/kiddin9/op-packages luci-app-taskplan
#git_sparse_clone main https://github.com/kiddin9/op-packages luci-app-timedreboot

# 安装主题
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon feeds/luci/themes/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config feeds/luci/applications/luci-app-argon-config
git clone --depth=1 https://github.com/eamonxg/luci-theme-aurora feeds/luci/themes/luci-theme-aurora
git clone --depth=1 https://github.com/eamonxg/luci-app-aurora-config feeds/luci/applications/luci-app-aurora-config

# 清理所有临时缓存和索引 (让系统自动重建，而不是手动删行)
# 这会清除所有 feeds 的 .tmp 目录，强制系统在下次 update 时重新扫描
# 如果有其他自定义 feed，也建议清理对应的 .tmp 目录
rm -rf feeds/luci.tmp
rm -rf feeds/packages.tmp
# rm -rf feeds/base.tmp

./scripts/feeds update -a
./scripts/feeds install -a
