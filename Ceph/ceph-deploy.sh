#!/usr/bin/bash
# PYTHON VENV COMMANDS:
python3 -m venv ceph
cd ceph
. bin/activate
pip3 install git+https://github.com/ceph/ceph-deploy.git

# CEPH-DEPLOY COMMANDS:
ceph-deploy --username root new ceph01 ceph02 ceph03
ceph-deploy --username root install ceph01 ceph02 ceph03 --release pacific --mon --mgr --mds --osd
ceph-deploy --username root mon create ceph01 ceph02 ceph03
ceph-deploy --username root gatherkeys ceph01 ceph02 ceph03
ceph-deploy --username root admin ceph01 ceph02 ceph03
ceph-deploy --username root mgr create ceph01 ceph02 ceph03
ceph-deploy --username root mds create ceph01 ceph02 ceph03
ceph-deploy --username root osd create --data /dev/sdb ceph01
ceph-deploy --username root osd create --data /dev/sdc ceph01
ceph-deploy --username root osd create --data /dev/sdb ceph02
ceph-deploy --username root osd create --data /dev/sdc ceph02
ceph-deploy --username root osd create --data /dev/sdb ceph03
ceph-deploy --username root osd create --data /dev/sdc ceph03

# CEPHFS SETUP COMMANDS:
ceph osd pool create persist-cephfs_data 8
ceph osd pool create persist-cephfs_metadata 8
ceph fs new persist-cephfs persist-cephfs_metadata persist-cephfs_data
ceph fs set persist-cephfs allow_new_snaps true