#
# Copyright (C) 2011 ezbox project
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#
include $(TOPDIR)/rules.mk

ARCH:=arm
BOARD:=hi35xx
BOARDNAME:=Hisilicon HI35xx
FEATURES:=jffs2
CFLAGS:=-O2 -pipe -march=armv5te -mtune=arm926ej-s -fno-caller-saves
SUBTARGETS:=generic

LINUX_VERSION:=2.6.32.32

define Target/Description
	HI35xx ARM
endef

include $(INCLUDE_DIR)/target.mk

$(eval $(call BuildTarget))
