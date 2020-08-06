#!/bin/bash

PKGNAME="youdao-dict"
VERSION="6.0.0"
ARCH="amd64"
GZFILE="$PKGNAME-$VERSION-$ARCH.tar.gz"
GZFILEURL="http://codown.youdao.com/cidian/linux/$GZFILE"
SRCFOLDER="$PKGNAME-$VERSION-$ARCH"
MD5HASH="4ea02c47e14aeebfbb892b7a14dad67d"

sudo apt-get install build-essential

sudo rm -rf build try

rm -rf $GZFILE
rm -rf $SRCFOLDER
wget $GZFILEURL
tar zxvf $GZFILE

MD5STR=`md5sum $GZFILE | awk '{ print $1 }'`

if [ "$VAR1" = "$VAR2" ]; then
    echo "md5hash string are equal."
else
    echo "md5hash string not equal."
    exit
fi 

SRCSIZE=`du -sk $SRCFOLDER | awk '{ print $1 }'`
echo "target installed size: $SRCSIZE"


mkdir build -p
mkdir try -p
mkdir try/DEBIAN -p
mkdir try/usr -p

echo "Package: $PKGNAME" > try/DEBIAN/control
echo "Version: $VERSION" >> try/DEBIAN/control
echo "Architecture: $ARCH" >> try/DEBIAN/control
echo "Provides: $PKGNAME" >> try/DEBIAN/control
echo "Conflicts: $PKGNAME" >> try/DEBIAN/control
echo "Replaces: $PKGNAME" >> try/DEBIAN/control
echo "Installed-Size: $SRCSIZE" >> try/DEBIAN/control
echo "Description: Youdao Dict" >> try/DEBIAN/control
echo "Maintainer: Maintainer <gzhechu@gmail.com>" >> try/DEBIAN/control
echo "Section: utils" >> try/DEBIAN/control
echo "Depends: tesseract-ocr, tesseract-ocr-eng, tesseract-ocr-chi-sim, python3-xdg, python3-opengl, python3-xlib" >> try/DEBIAN/control
echo "Homepage: https://cidian.youdao.com/" >> try/DEBIAN/control
echo "Priority: optional" >> try/DEBIAN/control

cd $SRCFOLDER
PREFIX=../try/usr


mkdir -p $PREFIX/bin
mkdir -p $PREFIX/share/youdao-dict
mkdir -p $PREFIX/share/applications
mkdir -p $PREFIX/share/dbus-1/services
mkdir -p $PREFIX/share/icons/hicolor/48x48/apps
mkdir -p $PREFIX/share/icons/hicolor/scalable/apps
mkdir -p $PREFIX/etc/xdg/autostart
cp -r src/* $PREFIX/share/youdao-dict
cp -r data/hicolor/* $PREFIX/share/icons/hicolor/
cp data/youdao-dict.desktop $PREFIX/share/applications/
# cp data/youdao-dict-autostart.desktop $PREFIX/etc/xdg/autostart/
cp data/com.youdao.backend.service $PREFIX/share/dbus-1/services/
chmod 755 $PREFIX/share/youdao-dict/main.py
chmod 755 $PREFIX/share/youdao-dict/youdao-dict-backend.py
BIN_PATH=$PREFIX/bin/youdao-dict
ln -sf /usr/share/youdao-dict/main.py $BIN_PATH
sudo chown -R root. $PREFIX

cd ..
sudo dpkg-deb --build try build
