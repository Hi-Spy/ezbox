#
# Copyright (C) 2006-2009 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

ARCH:=arm
BOARD:=s3c24xx
BOARDNAME:=Samsung S3C24xx
FEATURES:=jffs2
CFLAGS:=-O2 -pipe -march=armv4t -mtune=arm920t -fno-caller-saves
SUBTARGETS:=generic openmoko-gta02

LINUX_VERSION:=2.6.37.6

DEVICE_TYPE?=phone

define Target/Description
	S3C24xx arm
endef

include $(INCLUDE_DIR)/target.mk

$(eval $(call BuildTarget))
