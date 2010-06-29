#
# Copyright (C) 2006-2010 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

CRYPTO_MENU:=Cryptographic API modules

# XXX: added workarounds for modules renamed in 2.6 series:
#  - aes > aes_generic (2.6.24)
#  - blkcipher -> crypto_blkcipher (2.6.25)
#  - des > des_generic (2.6.24)
#  - sha1 > sha1_generic (2.6.24)
#  - sha256 > sha256_generic (2.6.24)
#  - sha512 > sha512_generic (2.6.26)
ifneq ($(CONFIG_LINUX_2_6),)
  CRYPTO_GENERIC:=_generic
  AES_SUFFIX:=$(CRYPTO_GENERIC)
  DES_SUFFIX:=$(CRYPTO_GENERIC)
  SHA1_SUFFIX:=$(CRYPTO_GENERIC)
  SHA256_SUFFIX:=$(CRYPTO_GENERIC)
  SHA512_SUFFIX:=$(CRYPTO_GENERIC)
endif

CRYPTO_MODULES = \
	ALGAPI=crypto_algapi \
	AEAD2=aead \
	PCOMP=pcompress \
	BLKCIPHER2=crypto_blkcipher \
	HASH2=crypto_hash \
	MANAGER2=cryptomgr \
	CBC=cbc \
	ECB=ecb \
	DEFLATE=deflate

crypto_confvar=CONFIG_CRYPTO_$(word 1,$(subst =,$(space),$(1)))
crypto_file=$(if $(findstring y,$($(call crypto_confvar,$(1)))),,$(LINUX_DIR)/crypto/$(word 2,$(subst =,$(space),$(1))).$(LINUX_KMOD_SUFFIX))
crypto_name=$(if $(findstring y,$($(call crypto_confvar,$(1)))),,$(word 2,$(subst =,$(space),$(1))))

# XXX: added CONFIG_CRYPTO_HMAC to KCONFIG so that CONFIG_CRYPTO_HASH is
# always set, even if no hash modules are selected
define KernelPackage/crypto-core
  SUBMENU:=$(CRYPTO_MENU)
  TITLE:=Core CryptoAPI modules
  KCONFIG:=CONFIG_CRYPTO=y CONFIG_CRYPTO_HMAC $(foreach mod,$(CRYPTO_MODULES),$(call crypto_confvar,$(mod)))
  FILES:=$(foreach mod,$(CRYPTO_MODULES),$(call crypto_file,$(mod)))
  AUTOLOAD:=$(call AutoLoad,01,$(foreach mod,$(CRYPTO_MODULES),$(call crypto_name,$(mod))))
endef

define KernelPackage/crypto-core/2.4
  FILES:=$(LINUX_DIR)/crypto/deflate.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,01, deflate)
endef

$(eval $(call KernelPackage,crypto-core))


define AddDepends/crypto
  SUBMENU:=$(CRYPTO_MENU)
  DEPENDS+=kmod-crypto-core $(1)
endef


define KernelPackage/crypto-hw-padlock
  TITLE:=VIA PadLock ACE with AES/SHA hw crypto module
  DEPENDS:=@LINUX_2_6
  KCONFIG:= \
	CONFIG_CRYPTO_HW=y \
	CONFIG_CRYPTO_DEV_PADLOCK \
	CONFIG_CRYPTO_DEV_PADLOCK_AES \
	CONFIG_CRYPTO_DEV_PADLOCK_SHA
  FILES:= \
	$(LINUX_DIR)/drivers/crypto/padlock-aes.$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/drivers/crypto/padlock-sha.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,09,padlock-aes padlock-sha)
  $(call AddDepends/crypto)
endef

$(eval $(call KernelPackage,crypto-hw-padlock))


define KernelPackage/crypto-hw-geode
  TITLE:=AMD Geode hardware crypto module
  DEPENDS:=@LINUX_2_6
  KCONFIG:= \
	CONFIG_CRYPTO_HW=y \
	CONFIG_CRYPTO_DEV_GEODE
  FILES:=$(LINUX_DIR)/drivers/crypto/geode-aes.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,09,geode-aes)
  $(call AddDepends/crypto)
endef

$(eval $(call KernelPackage,crypto-hw-geode))


define KernelPackage/crypto-hw-hifn-795x
  TITLE:=HIFN 795x crypto accelerator
  DEPENDS:=@LINUX_2_6 @!TARGET_ubicom32
  KCONFIG:= \
	CONFIG_CRYPTO_HW=y \
	CONFIG_HW_RANDOM=y \
	CONFIG_CRYPTO_DEV_HIFN_795X \
	CONFIG_CRYPTO_DEV_HIFN_795X_RNG=y
  FILES:=$(LINUX_DIR)/drivers/crypto/hifn_795x.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,09,hifn_795x)
  $(call AddDepends/crypto,+kmod-crypto-des)
endef

$(eval $(call KernelPackage,crypto-hw-hifn-795x))


define KernelPackage/crypto-hw-ixp4xx
  TITLE:=Intel IXP4xx hardware crypto module
  DEPENDS:=@TARGET_ixp4xx
  KCONFIG:= \
	CONFIG_CRYPTO_HW=y \
	CONFIG_CRYPTO_DEV_IXP4XX
  FILES:=$(LINUX_DIR)/drivers/crypto/ixp4xx_crypto.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,90,ixp4xx_crypto)
  $(call AddDepends/crypto,+kmod-crypto-authenc +kmod-crypto-des)
endef

define KernelPackage/crypto-hw-ixp4xx/description
  Kernel support for the Intel IXP4xx HW crypto engine.
endef

$(eval $(call KernelPackage,crypto-hw-ixp4xx))


define KernelPackage/crypto-hw-ppc4xx
  TITLE:=AMCC PPC4xx hardware crypto module
  DEPENDS:=@TARGET_ppc40x||TARGET_ppc44x
  KCONFIG:= \
	CONFIG_CRYPTO_HW=y \
	CONFIG_CRYPTO_DEV_PPC4XX
  FILES:=$(LINUX_DIR)/drivers/crypto/amcc/crypto4xx.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,90,crypto4xx)
  $(call AddDepends/crypto)
endef

define KernelPackage/crypto-hw-ppc4xx/description
  Kernel support for the AMCC PPC4xx HW crypto engine.
endef

$(eval $(call KernelPackage,crypto-hw-ppc4xx))


define KernelPackage/crypto-aes
  TITLE:=AES cipher CryptoAPI module
  KCONFIG:=CONFIG_CRYPTO_AES CONFIG_CRYPTO_AES_586
  FILES:=$(LINUX_DIR)/crypto/aes$(AES_SUFFIX).$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,09,aes$(AES_SUFFIX))
  $(call AddDepends/crypto)
endef

define KernelPackage/crypto-aes/x86
  FILES+=$(LINUX_DIR)/arch/x86/crypto/aes-i586.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,09,aes$(AES_SUFFIX) aes-i586)
endef

$(eval $(call KernelPackage,crypto-aes))


define KernelPackage/crypto-arc4
  TITLE:=ARC4 (RC4) cipher CryptoAPI module
  KCONFIG:=CONFIG_CRYPTO_ARC4
  FILES:=$(LINUX_DIR)/crypto/arc4.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,09,arc4)
  $(call AddDepends/crypto)
endef

$(eval $(call KernelPackage,crypto-arc4))


define KernelPackage/crypto-authenc
  TITLE:=Combined mode wrapper for IPsec
  KCONFIG:=CONFIG_CRYPTO_AUTHENC
  FILES:=$(LINUX_DIR)/crypto/authenc.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,09,authenc)
  $(call AddDepends/crypto)
endef

$(eval $(call KernelPackage,crypto-authenc))

define KernelPackage/crypto-des
  TITLE:=DES/3DES cipher CryptoAPI module
  KCONFIG:=CONFIG_CRYPTO_DES
  FILES:=$(LINUX_DIR)/crypto/des$(DES_SUFFIX).$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,09,des$(DES_SUFFIX))
  $(call AddDepends/crypto)
endef

$(eval $(call KernelPackage,crypto-des))


define KernelPackage/crypto-hmac
  TITLE:=HMAC digest CryptoAPI module
  KCONFIG:=CONFIG_CRYPTO_HMAC
  FILES:=$(LINUX_DIR)/crypto/hmac.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,09,hmac)
  $(call AddDepends/crypto)
endef

$(eval $(call KernelPackage,crypto-hmac))


define KernelPackage/crypto-md5
  TITLE:=MD5 digest CryptoAPI module
  KCONFIG:=CONFIG_CRYPTO_MD5
  FILES:=$(LINUX_DIR)/crypto/md5.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,09,md5)
  $(call AddDepends/crypto)
endef

$(eval $(call KernelPackage,crypto-md5))


define KernelPackage/crypto-michael-mic
  TITLE:=Michael MIC keyed digest CryptoAPI module
  KCONFIG:=CONFIG_CRYPTO_MICHAEL_MIC
  FILES:=$(LINUX_DIR)/crypto/michael_mic.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,09,michael_mic)
  $(call AddDepends/crypto)
endef

$(eval $(call KernelPackage,crypto-michael-mic))


define KernelPackage/crypto-sha1
  TITLE:=SHA1 digest CryptoAPI module
  KCONFIG:=CONFIG_CRYPTO_SHA1
  FILES:=$(LINUX_DIR)/crypto/sha1$(SHA1_SUFFIX).$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,09,sha1$(SHA1_SUFFIX))
  $(call AddDepends/crypto)
endef

$(eval $(call KernelPackage,crypto-sha1))


define KernelPackage/crypto-misc
  TITLE:=Other CryptoAPI modules
  KCONFIG:= \
	CONFIG_CRYPTO_ANUBIS \
	CONFIG_CRYPTO_BLOWFISH \
	CONFIG_CRYPTO_CAMELLIA \
	CONFIG_CRYPTO_CAST5 \
	CONFIG_CRYPTO_CAST6 \
	CONFIG_CRYPTO_CRC32C \
	CONFIG_CRYPTO_FCRYPT \
	CONFIG_CRYPTO_KHAZAD \
	CONFIG_CRYPTO_MD4 \
	CONFIG_CRYPTO_SERPENT \
	CONFIG_CRYPTO_SHA256 \
	CONFIG_CRYPTO_SHA512 \
	CONFIG_CRYPTO_TEA \
	CONFIG_CRYPTO_TGR192 \
	CONFIG_CRYPTO_TWOFISH \
	CONFIG_CRYPTO_TWOFISH_COMMON \
	CONFIG_CRYPTO_TWOFISH_586 \
	CONFIG_CRYPTO_WP512
  FILES:= \
	$(LINUX_DIR)/crypto/anubis.$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/blowfish.$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/cast5.$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/cast6.$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/khazad.$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/md4.$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/serpent.$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/sha256$(SHA256_SUFFIX).$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/sha512$(SHA512_SUFFIX).$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/tea.$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/twofish.$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/wp512.$(LINUX_KMOD_SUFFIX)
  $(call AddDepends/crypto)
endef

define KernelPackage/crypto-misc/2.6
  FILES+= \
	$(LINUX_DIR)/crypto/camellia.$(LINUX_KMOD_SUFFIX) \
	$(if $(findstring y,$(CONFIG_CRYPTO_CRC32C)),,$(LINUX_DIR)/crypto/crc32c.$(LINUX_KMOD_SUFFIX)) \
	$(LINUX_DIR)/crypto/fcrypt.$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/tgr192.$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/twofish_common.$(LINUX_KMOD_SUFFIX)
endef

define KernelPackage/crypto-misc/x86
  FILES+=$(LINUX_DIR)/arch/x86/crypto/twofish-i586.$(LINUX_KMOD_SUFFIX)
endef

$(eval $(call KernelPackage,crypto-misc))


define KernelPackage/crypto-ocf
  TITLE:=OCF modules
  DEPENDS:=+@OPENSSL_ENGINE @!TARGET_uml
  KCONFIG:= \
	CONFIG_OCF_OCF \
	CONFIG_OCF_CRYPTODEV \
	CONFIG_OCF_CRYPTOSOFT \
	CONFIG_OCF_FIPS=y \
	CONFIG_OCF_RANDOMHARVEST=y
  FILES:= \
	$(LINUX_DIR)/crypto/ocf/ocf.$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/ocf/cryptodev.$(LINUX_KMOD_SUFFIX) \
	$(LINUX_DIR)/crypto/ocf/cryptosoft.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,09, \
	ocf \
	cryptodev \
	cryptosoft \
  )
  $(call AddDepends/crypto)
endef

$(eval $(call KernelPackage,crypto-ocf))


define KernelPackage/crypto-ocf-hifn7751
  TITLE:=OCF support for Hifn 6500/7751/7811/795x, Invertex AEON and NetSec 7751 devices
  DEPENDS:=+@OPENSSL_ENGINE @PCI_SUPPORT @!TARGET_uml kmod-crypto-ocf
  KCONFIG:=CONFIG_OCF_HIFN
  FILES:=$(LINUX_DIR)/crypto/ocf/hifn/hifn7751.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,10,hifn7751)
  $(call AddDepends/crypto)
endef

$(eval $(call KernelPackage,crypto-ocf-hifn7751))


define KernelPackage/crypto-ocf-hifnhipp
  TITLE:=OCF support for Hifn 7855/8155 devices
  DEPENDS:=+@OPENSSL_ENGINE @PCI_SUPPORT @!TARGET_uml kmod-crypto-ocf
  KCONFIG:=CONFIG_OCF_HIFNHIPP
  FILES:=$(LINUX_DIR)/crypto/ocf/hifn/hifnHIPP.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,10,hifnhipp)
  $(call AddDepends/crypto)
endef

$(eval $(call KernelPackage,crypto-ocf-hifnhipp))


define KernelPackage/crypto-null
  TITLE:=Null CryptoAPI module
  KCONFIG:=CONFIG_CRYPTO_NULL
  FILES:=$(LINUX_DIR)/crypto/crypto_null.$(LINUX_KMOD_SUFFIX)
  AUTOLOAD:=$(call AutoLoad,09,crypto_null)
  $(call AddDepends/crypto)
endef

$(eval $(call KernelPackage,crypto-null))


define KernelPackage/crypto-test
  TITLE:=Test CryptoAPI module
  KCONFIG:=CONFIG_CRYPTO_TEST
  FILES:=$(LINUX_DIR)/crypto/tcrypt.$(LINUX_KMOD_SUFFIX)
  $(call AddDepends/crypto)
endef

$(eval $(call KernelPackage,crypto-test))
