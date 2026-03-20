### AnyKernel3 Ramdisk Mod Script
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=LoungeAct Kernel by Vinix120Hz
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=x1s
device.name2=x1slte
device.name3=y2s
device.name4=y2slte
device.name5=z3s
device.name6=c1s
device.name7=c1slte
device.name8=c2s
device.name9=c2slte
device.name10=r8s
supported.versions=11, 12, 13, 14, 15, 16
supported.patchlevels=
'; } # end properties

### AnyKernel install
## boot files attributes
boot_attributes() {
set_perm_recursive 0 0 755 644 $RAMDISK/*;
set_perm_recursive 0 0 750 750 $RAMDISK/init* $RAMDISK/sbin;
} # end attributes

# boot shell variables
BLOCK=/dev/block/by-name/boot;
IS_SLOT_DEVICE=1;
RAMDISK_COMPRESSION=auto;
PATCH_VBMETA_FLAG=auto;

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh;

# boot install
dump_boot; # O AnyKernel vai abrir o seu boot.img AOSP aqui

# O AnyKernel3 vai substituir automaticamente o arquivo 'Image' e 'dtb' 
# que o seu build.sh copiou para a pasta raiz.

write_boot; # Aqui ele fecha o novo boot.img com o seu kernel e o ramdisk original
## end boot install
