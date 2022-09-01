#!/bin/bash
# Based on https://lukas.zapletalovi.com/2019/05/lvm-cache-in-six-easy-steps.html
if [ "$#" -ne 5 ]; then
  echo "You must enter exactly all command line arguments"
  echo ""
  echo "Slow PV = $1"
  echo "Fast PV = $2"
  echo "Volume Group = $3"
  echo "Slow LV = $4"
  echo "Fast LV = $5"
  exit 1
else 
echo "Creating LVM Cache" 
  PV_SLOW=$1
  PV_FAST=$2
  VG=$3
  LV_SLOW=$4
  LV_FAST=$5
  pvcreate $PV_SLOW
  pvcreate $PV_FAST
  vgcreate $VG $PV_SLOW $PV_FAST
  lvcreate -l 100%PVS -n $LV_SLOW $VG $PV_SLOW
  lvcreate -l 100%PVS -n $LV_FAST $VG $PV_FAST
  lvconvert --type cache --cachevol $LV_FAST $VG/$LV_SLOW
  lvchange --cachemode writeback $VG/$LV_SLOW
  mkfs.ext4 $LV_SLOW
fi

#this is my wd red drive (slow PV)
pvcreate $PV_SLOW
vgcreate $VG $PV_SLOW

this is the optane drive (fast PV)
pvcreate $PV_FAST
vgextend $VG $PV_FAST

#creating the slow & large LV
lvcreate -n red4tb -L 2t $VG $PV_SLOW

#take note that the PV is specifed when creating the fast LV
lvcreate -n cac0 -L 100g $VG $PV_FAST

take note that the PV is specifed when creating the metadata LV
lvcreate -n met0 -L 122m $VG $PV_FAST

#creates the cache by combining the cache and meta LVs
lvconvert --type cache-pool --poolmetadata $VG/met0 $VG/cac0

#combines the cache and slow LVs
lvconvert --type cache --cachepool $VG/cac0 $VG/red4tb

#change the cache mode to writeback
lvchange --cachemode writeback $VG/red4tb

lvs -o+cache_mode $VG/red4tb

lva -a $VG
