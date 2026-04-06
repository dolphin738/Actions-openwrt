#!/bin/bash

#feed修改
#sed -i 's|https://github.com/qosmio/sqm-scripts-nss.git|https://github.com/JuliusBairaktaris/sqm-scripts-nss.git|g' feeds.conf.default
sed -i 's|https://github.com/immortalwrt/packages.git|https://github.com/immortalwrt/packages.git;openwrt-25.12|g' feeds.conf.default
sed -i 's|https://github.com/immortalwrt/luci.git|https://github.com/immortalwrt/luci.git;openwrt-25.12|g' feeds.conf.default
sed -i 's|https://github.com/openwrt/routing.git|https://github.com/openwrt/routing.git;openwrt-25.12|g' feeds.conf.default
sed -i 's|https://github.com/openwrt/telephony.git|https://github.com/openwrt/telephony.git;openwrt-25.12|g' feeds.conf.default
sed -i 's|https://github.com/openwrt/video.git|https://github.com/openwrt/video.git;openwrt-25.12|g' feeds.conf.default
