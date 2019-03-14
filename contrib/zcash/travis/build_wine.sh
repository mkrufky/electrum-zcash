#!/bin/bash

source ./contrib/zcash/travis/electrum_zcash_version_env.sh;
echo wine build version is $ELECTRUM_ZCASH_VERSION

mv /opt/zbarw $WINEPREFIX/drive_c/
cd $WINEPREFIX/drive_c/electrum-zcash

rm -rf build
rm -rf dist/electrum-zcash

cp contrib/zcash/deterministic.spec .
cp contrib/zcash/pyi_runtimehook.py .
cp contrib/zcash/pyi_tctl_runtimehook.py .

wine pip install --upgrade pip==18.1
export PYINSTALLER_TAG=dev180610
wget https://github.com/zebra-lucky/pyinstaller/archive/$PYINSTALLER_TAG.tar.gz
wine pip install $PYINSTALLER_TAG.tar.gz
rm $PYINSTALLER_TAG.tar.gz

wine pip install -r contrib/zcash/requirements.txt
wine pip install -I eth-hash==0.1.2
wine pip install -I eth-utils==1.0.3

wine pip install cython
wine pip install hidapi
wine pip install pycryptodomex==3.6.0
wine pip install btchip-python==0.1.26
wine pip install keepkey==4.0.2
wine pip install trezor==0.9.1

mkdir $WINEPREFIX/drive_c/Qt
ln -s $PYHOME/Lib/site-packages/PyQt5/ $WINEPREFIX/drive_c/Qt/5.5.1

wine pyinstaller -y \
    --name electrum-zcash-$ELECTRUM_ZCASH_VERSION.exe \
    deterministic.spec

if [[ $WINEARCH == win32 ]]; then
    NSIS_EXE="$WINEPREFIX/drive_c/Program Files/NSIS/makensis.exe"
else
    NSIS_EXE="$WINEPREFIX/drive_c/Program Files (x86)/NSIS/makensis.exe"
fi

wine "$NSIS_EXE" /NOCD -V3 \
    /DPRODUCT_VERSION=$ELECTRUM_ZCASH_VERSION \
    /DWINEARCH=$WINEARCH \
    contrib/zcash/electrum-zcash.nsi
