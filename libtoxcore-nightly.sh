#! /bin/sh
SOURCEVERSION=$(date +%Y%m%d)
REVISION="-1"
VERSION=$SOURCEVERSION$REVISION
TOXVERSION='toxcore'
under='_'
YOU="dmotc"
EMAIL="cmotc@openmailbox.org"
echo "$TOXVERSION debian package generation tool"
echo $TOXVERSION$under$VERSION
echo "Until further notice, the package versions"
echo "Will correspond to the date that the package"
echo "was compiled."
echo "--------------------------------------------"
echo "Cleaning up after last build"
rm -rf $TOXVERSION$under$VERSION
cd $TOXVERSION && make distclean
echo "Pulling most recent update from master branch"
git fetch upstream
git pull
cd ..
echo "Generating Original Tarball as $TOXVERSION$under$SOURCEVERSION.orig.tar.gz"
tar -pczf $TOXVERSION$under$SOURCEVERSION.orig.tar.gz $TOXVERSION
echo "Copying source code and creating debian build directory"
cp -r $TOXVERSION $TOXVERSION$under$VERSION
mkdir -p $TOXVERSION$under$VERSION/debian/source
echo "Populating $TOXVERSION$under$VERSION/debian directory with necessary files"
#cp $TOXVERSION$under$SOURCEVERSION.orig.tar.gz $TOXVERSION$under$VERSION/debian/$TOXVERSION$under$SOURCEVERSION.orig.tar.gz
#mkdir -p $TOXVERSION$under$VERSION/debian/sodium/usr/ && echo " " > $TOXVERSION$under$VERSION/debian/sodium/usr/include
echo "9" > $TOXVERSION$under$VERSION/debian/compat
echo "Source: $TOXVERSION
Maintainer: $YOU $EMAIL
Section: misc
Priority: optional
Build-Depends: build-essential (>= 11.7), libtool (>= 2.4.2-1.11), autotools-dev (>= 20140911.1), automake (>= 1:1.14.1-4), checkinstall (>= 1.6.2-4), check (>= 0.9.10-6.1), git (>= 1:2.1.3-1), yasm (>= 1.2.0-2), debhelper (>= 9) 

Package: lib$TOXVERSION
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: LibToxCore package for Debian.

Package: lib$TOXVERSION-dev
Architecture: all
Depends: \${shlibs:Depends}, \${misc:Depends}, libtoxcore(= $VERSION)
Homepage: https://libsodium.org
Description: LibToxCore development files " > $TOXVERSION$under$VERSION/debian/control
cp $TOXVERSION$under$VERSION/COPYING $TOXVERSION$under$VERSION/debian/copyright
echo "#!/usr/bin/make -f
%:
	dh \$@">$TOXVERSION$under$VERSION/debian/rules
echo '3.0 (quilt)' > $TOXVERSION$under$VERSION/debian/source/format
cd $TOXVERSION$under$VERSION/ 
rm debian/changelog
dch --create -v $VERSION --package $TOXVERSION
autoreconf -i
./configure --enable-av
dpkg-source --commit
debuild -d -us -uc 
pwd
cd ..
rm -rf toxcore-debhelper/$TOXVERSION
mv $TOXVERSION$under$VERSION toxcore-debhelper/$TOXVERSION
rm -rf toxcore-debhelper/$TOXVERSION/debian
mv lib$TOXVERSION*$under$VERSION* toxcore-debhelper/
mv $TOXVERSION$under$VERSION* toxcore-debhelper/
dpkg-sig --sign builder lib$TOXVERSION$under$VERSION*.deb
dpkg-sig --sign builder lib$TOXVERSION*$under$VERSION*.deb
cp libtoxcore-nightly.sh toxcore-debhelper/
cd toxcore-debhelper && gpsf
cd .. 
./updaterepo
