#! /bin/sh
SOURCEVERSION=$(date +%Y%m%d)
REVISION="-1"
VERSION=$SOURCEVERSION$REVISION
IIPVERSION='i2pd'
under='_'
YOU="dmotc"
EMAIL="cmotc@openmailbox.org"
echo "$IIPVERSION debian package generation tool"
echo $IIPVERSION$under$VERSION
echo "Until further notice, the package versions"
echo "Will correspond to the date that the package"
echo "was compiled."
echo "--------------------------------------------"
echo "Cleaning up after last build"
rm -rf $IIPVERSION$under$VERSION
cd $IIPVERSION && make distclean
echo "Pulling most recent update from master branch"
git pull upstream master
git pull origin master
cd ..
echo "Generating Original Tarball as $IIPVERSION$under$SOURCEVERSION.orig.tar.gz"
tar -pczf $IIPVERSION$under$SOURCEVERSION.orig.tar.gz $IIPVERSION
echo "Copying source code and creating debian build directory"
cp -r $IIPVERSION $IIPVERSION$under$VERSION
mkdir -p $IIPVERSION$under$VERSION/debian/source
echo "Populating $IIPVERSION$under$VERSION/debian directory with necessary files"
#cp $IIPVERSION$under$SOURCEVERSION.orig.tar.gz $IIPVERSION$under$VERSION/debian/$IIPVERSION$under$SOURCEVERSION.orig.tar.gz
#mkdir -p $IIPVERSION$under$VERSION/debian/sodium/usr/ && echo " " > $IIPVERSION$under$VERSION/debian/sodium/usr/include
echo "9" > $IIPVERSION$under$VERSION/debian/compat
echo "Source: $IIPVERSION
Maintainer: $YOU $EMAIL
Section: misc
Priority: optional
Build-Depends: build-essential (>= 11.7), libtool (>= 2.4.2-1.11), autotools-dev (>= 20140911.1), automake (>= 1:1.14.1-4), checkinstall (>= 1.6.2-4), check (>= 0.9.10-6.1), git (>= 1:2.1.3-1), yasm (>= 1.2.0-2), debhelper (>= 9), libcurl4-nss-dev (>= 7.38.00-4)

Package: $IIPVERSION
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: i2p C++ package for Anonymous, Peer-To-Peer post-internet networking.

Package: $IIPVERSION-dev
Architecture: all
Depends: \${shlibs:Depends}, \${misc:Depends}, twister-core(= $VERSION)
Homepage: https://github.com/purplei2p/i2pd
Description: i2p C++ package for Anonymous, Peer-To-Peer post-internet networking." > $IIPVERSION$under$VERSION/debian/control
cp $IIPVERSION$under$VERSION/COPYING $IIPVERSION$under$VERSION/debian/copyright
echo "#!/usr/bin/make -f
%:
	dh \$@">$IIPVERSION$under$VERSION/debian/rules
echo '3.0 (quilt)' > $IIPVERSION$under$VERSION/debian/source/format
cd $IIPVERSION$under$VERSION/ 
rm debian/changelog
dch --create -v $VERSION --package $IIPVERSION
#./autogen.sh
#./configure #--enable-av
dpkg-source --commit
debuild -d -us -uc 
pwd
cd ..
rm -rf toxcore-debhelper/$IIPVERSION
cp $IIPVERSION$under$VERSION toxcore-debhelper/$IIPVERSION
rm -rf toxcore-debhelper/$IIPVERSION/debian
cp $IIPVERSION*$under$VERSION* toxcore-debhelper/
cp $IIPVERSION$under$VERSION* toxcore-debhelper/
dpkg-sig -k FFECC302 --sign builder $IIPVERSION$under$VERSION*.deb
dpkg-sig -k FFECC302 --sign builder $IIPVERSION*$under$VERSION*.deb
cp i2pd-nightly.sh toxcore-debhelper/
cd toxcore-debhelper && gpsf
cd .. 
./updaterepo
