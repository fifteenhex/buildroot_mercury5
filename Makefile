DEFCONFIG=../br2midrive08/configs/midrive08_defconfig
EXTERNALS=../br2midrive08 ../br2sanetime

LINUXBRANCH=mstar_dev_v5_8_rebase_cleanup

define clean_pkg
        rm -rf $(1)/output/build/$(2)/
endef

define update_git_package
	@echo updating git package $(1)
	- git -C $(DLDIR)/$(1)/git clean -fd
	- git -C $(DLDIR)/$(1)/git checkout master
	- git -C $(DLDIR)/$(1)/git reset --hard origin/master
	- git -C $(DLDIR)/$(1)/git branch -D $(2)
	- git -C $(DLDIR)/$(1)/git fetch --force --all --tags
	- rm -f $(DLDIR)/$(1)/*.tar.gz
endef

.PHONY: all \
	bootstrap

all: buildroot

bootstrap.stamp:
	git submodule init
	git submodule update
	touch bootstrap.stamp

./br2secretsauce/common.mk: bootstrap.stamp

include ./br2secretsauce/common.mk
