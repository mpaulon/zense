RMDIR := rm -rf
MKDIR := mkdir -p

BUILD_DIR := build
INITRAMFS := $(BUILD_DIR)/initramfs
FS_DIRS := bin/ dev/ etc/ lib/ lib64/ mnt/root/ proc/ root/ sbin/ sys/
FS_TREE = $(patsubst %,$(INITRAMFS)/%,$(FS_DIRS))

KERNEL_DIR := ../linux
BUSYBOX_DIR := ../busybox


clean:
	$(RMDIR) $(BUILD_DIR)

mkdir:
	$(MKDIR) $(FS_TREE)

busybox: mkdir
	cp -av $(BUSYBOX_DIR)/_install/* $(INITRAMFS)

init: mkdir 
	cp init $(INITRAMFS)/init
	chmod +x $(INITRAMFS)/init

mkinitramfs: busybox init
	cd $(INITRAMFS) ; \
	find . -print0 | cpio --null -ov --format=newc \
	| gzip -9 > ../initramfs.cpio.gz

kernel: mkdir
	cp $(KERNEL_DIR)/arch/x86/boot/bzImage $(BUILD_DIR)/bzImage

build: mkinitramfs kernel

run: build
	qemu-system-x86_64 \
	-kernel $(BUILD_DIR)/bzImage \
	-initrd $(BUILD_DIR)/initramfs.cpio.gz \
	-nographic -enable-kvm \
	-append "console=ttyS0"

all: run