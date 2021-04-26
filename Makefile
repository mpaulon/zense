RMDIR := rm -rf
MKDIR := mkdir -p

BUILD_DIR := build
INITRAMFS := $(BUILD_DIR)/initramfs
FS_DIRS := bin/ dev/ etc/ lib/ lib64/ mnt/root/ proc/ root/ sbin/ sys/
FS_TREE = $(patsubst %,$(INITRAMFS)/%,$(FS_DIRS))

KERNEL_DIR := ../linux
BUSYBOX_DIR := ../busybox
CPYTHON_DIR := $(realpath -s ../cpython)
# compile stuff
python3:
	cp cpython/Modules/Setup $(CPYTHON_DIR)/Modules/Setup
	cd $(CPYTHON_DIR); \
	./configure LDFLAGS="-static -static-libgcc" CPPFLAGS="-fPIC -static" --disable-shared --prefix=$(CPYTHON_DIR)/_install &&\
	make -j5 && \
	make install

linux:
	cp linux/.config $(KERNEL_DIR)/.config
	cd $(KERNEL_DIR); \
	make -j5

busybox:
	cp busybox/.config $(BUSYBOX_DIR)/.config
	cd $(BUSYBOX_DIR); \
	make -j5 && \
	make install

clean:
	$(RMDIR) $(BUILD_DIR)

.mkdir:
	$(MKDIR) $(FS_TREE)

.busybox: .mkdir
	cp -av $(BUSYBOX_DIR)/_install/* $(INITRAMFS)

.python: .mkdir
	cp -av $(CPYTHON_DIR)/_install/* $(INITRAMFS)

.base_files: .mkdir 
	cp -av initramfs/* $(INITRAMFS)

.mkinitramfs: .busybox .base_files .python
	cd $(INITRAMFS) ; \
	find . -print0 | cpio --null -ov --format=newc \
	| gzip -9 > ../initramfs.cpio.gz

.kernel: .mkdir
	cp $(KERNEL_DIR)/arch/x86/boot/bzImage $(BUILD_DIR)/bzImage

build: .mkinitramfs .kernel

run: build
	qemu-system-x86_64 \
	-kernel $(BUILD_DIR)/bzImage \
	-initrd $(BUILD_DIR)/initramfs.cpio.gz \
	-nographic -enable-kvm \
	-m 512M \
	-append "console=ttyS0"

all: run