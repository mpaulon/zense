# Installation
## Dépendances
 * libelf-dev
 * fakeroot
 * bc
 * gcc
 * libncurses-dev
 * pkg-config
 * make
 * qemu-system
 * build-essential

## Compiler
### A la main

 * `git clone https://git.busybox.net/busybox/`
 * `git clone https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git`
 * copier les fichiers de configs à la racine des bons dossiers
 * pour le kernel: `make -j5`
 * pour busybox: `make -j5 && make install`
 * vérifier les paths de `KERNEL_DIR` et `BUSYBOX_DIR` dans le Makefile (par défaut on considère qu'ils ont été clonés dans le même dossier parent que ce repo)

### Avec le Makefile
 * `make linux`
 * `make busybox`
 * `make python3`

## Récupérer les fichiers initramfs et bzImage
 * `make build`

## Lancer tout ça dans qemu
 * `make run`

