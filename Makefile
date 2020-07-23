OUTPUTS=$(PWD)/outputs
DLDIR=$(PWD)/dl

BUILDROOT_PATH=./buildroot
BUILDROOT_ARGS=BR2_DEFCONFIG=../br2midrive08/configs/midrive08_defconfig \
        BR2_DL_DIR=$(DLDIR) \
	BR2_EXTERNAL="../br2midrive08"

LINUXBRANCH=mstar_dev_v5_8_rebase_cleanup

define clean_pkg
        rm -rf $(1)/output/build/$(2)/
endef

define update_git_package
	@echo updating git package $(1)
	git -C $(DLDIR)/$(1)/git clean -fd
	git -C $(DLDIR)/$(1)/git checkout master
	- git -C $(DLDIR)/$(1)/git reset --hard origin/master
	- git -C $(DLDIR)/$(1)/git branch -D $(2)
	git -C $(DLDIR)/$(1)/git fetch --force --all --tags
	rm -f $(DLDIR)/$(1)/*.tar.gz
endef

.PHONY: all \
	bootstrap \
	buildroot_config \
	buildroot \
	buildroot_dl \
	linux_clean \
	linux_update


all: buildroot

$(OUTPUTS):
	mkdir -p $(OUTPUTS)

$(DLDIR):
	mkdir -p $(DLDIR)

bootstrap:
	git submodule init
	git submodule update

buildroot_config:
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) defconfig
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) menuconfig
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) savedefconfig

buildroot: $(OUTPUTS) $(DLDIR)
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) defconfig
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS)

buildroot_dl: $(OUTPUTS) $(DLDIR)
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) defconfig
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) source

buildroot_linux_menuconfig:
	$(MAKE) -C $(BUILDROOT_PATH) $(BUILDROOT_ARGS) linux-menuconfig

linux_clean:
	$(call clean_pkg,$(BUILDROOT_PATH),$(LINUXBRANCH))

linux_update: linux_clean
	$(call update_git_package,linux,$(LINUXBRANCH))

clean:
	$(MAKE)	-C $(BUILDROOT_PATH) clean
