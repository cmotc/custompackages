#! /bin/sh
SOURCEVERSION=$(date +%Y%m%d)
REVISION="-1"
VERSION=$SOURCEVERSION$REVISION
FBTUNVERSION='facebook-tunnel'
under='_'
YOU="dmotc"
EMAIL="cmotc@openmailbox.org"
echo "$FBTUNVERSION debian package generation tool"
echo $FBTUNVERSION$under$VERSION
echo "Until further notice, the package versions"
echo "Will correspond to the date that the package"
echo "was compiled."
echo "--------------------------------------------"
echo "Cleaning up after last build"
rm -rf $FBTUNVERSION$under$VERSION
cd $FBTUNVERSION && make distclean
echo "Pulling most recent update from master branch"
git pull upstream master
git pull origin master
cd ..
echo "Generating Original Tarball as $FBTUNVERSION$under$SOURCEVERSION.orig.tar.gz"
tar -pczf $FBTUNVERSION$under$SOURCEVERSION.orig.tar.gz $FBTUNVERSION
echo "Copying source code and creating debian build directory"
cp -r $FBTUNVERSION $FBTUNVERSION$under$VERSION
mkdir -p $FBTUNVERSION$under$VERSION/debian/source
echo "Populating $FBTUNVERSION$under$VERSION/debian directory with necessary files"
#cp $FBTUNVERSION$under$SOURCEVERSION.orig.tar.gz $FBTUNVERSION$under$VERSION/debian/$FBTUNVERSION$under$SOURCEVERSION.orig.tar.gz
#mkdir -p $FBTUNVERSION$under$VERSION/debian/sodium/usr/ && echo " " > $FBTUNVERSION$under$VERSION/debian/sodium/usr/include
echo "9" > $FBTUNVERSION$under$VERSION/debian/compat
echo "Source: $FBTUNVERSION
Maintainer: $YOU $EMAIL
Section: misc
Priority: optional
Build-Depends: build-essential (>= 11.7), libtool (>= 2.4.2-1.11), autotools-dev (>= 20140911.1), automake (>= 1:1.14.1-4), checkinstall (>= 1.6.2-4), check (>= 0.9.10-6.1), git (>= 1:2.1.3-1), yasm (>= 1.2.0-2), debhelper (>= 9), libcurl4-nss-dev (>= 7.38.00-4)

Package: $FBTUNVERSION
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: Facebook-Tunnel package for Debian(CONTRIB AT BEST, ENCOURAGES THE USE OF FACEBOOK ALBEIT AS A MEANS TO AN END.)

Package: $FBTUNVERSION-dev
Architecture: all
Depends: \${shlibs:Depends}, \${misc:Depends}, twister-core(= $VERSION)
Homepage: https://github.com/matiasinsaurralde/facebook-tunnel
Description: Facebook-Tunnel package for Debian(CONTRIB AT BEST, ENCOURAGES THE USE OF FACEBOOK ALBEIT AS A MEANS TO AN END.)" > $FBTUNVERSION$under$VERSION/debian/control
cp $FBTUNVERSION$under$VERSION/COPYING $FBTUNVERSION$under$VERSION/debian/copyright
echo "#!/usr/bin/make -f
%:
	dh \$@">$FBTUNVERSION$under$VERSION/debian/rules
echo '3.0 (quilt)' > $FBTUNVERSION$under$VERSION/debian/source/format
cd $FBTUNVERSION$under$VERSION/ 
rm debian/changelog
dch --create -v $VERSION --package $FBTUNVERSION
./bootstrap.sh
./configure #--enable-av
dpkg-source --commit
debuild -d -us -uc 
pwd
cd ..
rm -rf toxcore-debhelper/$FBTUNVERSION
cp $FBTUNVERSION$under$VERSION toxcore-debhelper/$FBTUNVERSION
rm -rf toxcore-debhelper/$FBTUNVERSION/debian
cp $FBTUNVERSION*$under$VERSION* toxcore-debhelper/
cp $FBTUNVERSION$under$VERSION* toxcore-debhelper/
dpkg-sig -k FFECC302 --sign builder $FBTUNVERSION$under$VERSION*.deb
dpkg-sig -k FFECC302 --sign builder $FBTUNVERSION*$under$VERSION*.deb
cp fbtunnel-nightly.sh toxcore-debhelper/
cd toxcore-debhelper && gpsf
cd .. 
./updaterepo