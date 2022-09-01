#!/bin/bash
clear
if [ "$#" -ne 5 ]; then
  echo "You must enter exactly all command line arguments"
  echo ""
  echo "Slow PV = $1"
  echo "Fast PV = $2"
  echo "Volume Group = $3"
  echo "Slow LV = $4"
  echo "Fast LV = $5"
  echo "Logical Volume Name = $6"
  echo "Logincal Volume Size (% of PV) $7"
  exit 1
else 
echo "Creating LVM Cache" 
  PV_SLOW=$1
  PV_FAST=$2
  VG=$3
  #LV_SLOW=$4
  #LV_FAST=$5
  LV_NAME=$4
  LV_SIZE="${5}VG"
fi

echo ""
echo "Slow PV = $1"
echo "Fast PV = $2"
echo "Volume Group = $3"
#echo "Slow LV = $4"
#echo "Fast LV = $5"
echo "Logical Volume Name = $4"
echo "Logincal Volume Size (% of PV) $5"
echo ""

#this is my wd red drive (slow PV)
echo "pvcreate $PV_SLOW"
echo "vgcreate $VG $PV_SLOW"

#this is the optane drive (fast PV)
echo "pvcreate $PV_FAST"
echo "vgextend $VG $PV_FAST"

#creating the slow & large LV
echo "lvcreate -n $LV_NAME -l $LV_SIZE $VG $PV_SLOW"

#take note that the PV is specifed when creating the fast LV
echo "lvcreate -n cac-$VG -L 32g $VG $PV_FAST"

#take note that the PV is specifed when creating the metadata LV
echo "lvcreate -n met-$VG -L 128m $VG $PV_FAST"

#creates the cache by combining the cache and meta LVs
echo "lvconvert --type cache-pool --poolmetadata $VG/met-$VG $VG/cac-$VG"

#combines the cache and slow LVs
echo "lvconvert --type cache --cachepool $VG/cac-$VG $VG/$LV_NAME"

#change the cache mode to writeback
echo "lvchange --cachemode writeback $VG/$LV_NAME"

echo "lvs -o+cache_mode $VG/$LV_NAME"

echo "lvs -a $VG"

# https://www.howtogeek.com/442101/how-to-move-your-linux-home-directory-to-another-hard-drive/
# https://webhostinggeeks.com/howto/4-lvcreate-command-examples-on-linux/#:~:text=lvcreate%20is%20the%20command%20to,space%20in%20the%20physical%20volumes.