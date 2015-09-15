#! /bin/sh
SOURCEVERSION=$(date +%Y%m%d)
REVISION="-1"
VERSION=$SOURCEVERSION$REVISION
PGKVERSION='pidgin-gnome-keyring'
under='_'
YOU="cmotc"
EMAIL="cmotc@openmailbox.org"
echo "$PGKVERSION debian package generation tool"
echo $PGKVERSION$under$VERSION
echo "Until further notice, the package versions"
echo "Will correspond to the date that the package"
echo "was compiled."
echo "--------------------------------------------"
echo "Cleaning up after last build"
rm -rf $PGKVERSION$under$VERSION
cd $PGKVERSION && make distclean
echo "Pulling most recent update from master branch"
git fetch upstream
git pull
cd ..
echo "Generating Original Tarball as $PGKVERSION$under$SOURCEVERSION.orig.tar.gz"
tar -pczf $PGKVERSION$under$SOURCEVERSION.orig.tar.gz $PGKVERSION
echo "Copying source code and creating debian build directory"
cp -r $PGKVERSION $PGKVERSION$under$VERSION
mkdir -p $PGKVERSION$under$VERSION/debian/source
echo "Populating $PGKVERSION$under$VERSION/debian directory with necessary files"
#cp $PGKVERSION$under$SOURCEVERSION.orig.tar.gz $PGKVERSION$under$VERSION/debian/$PGKVERSION$under$SOURCEVERSION.orig.tar.gz
#mkdir -p $PGKVERSION$under$VERSION/debian/sodium/usr/ && echo " " > $PGKVERSION$under$VERSION/debian/sodium/usr/include
echo "9" > $PGKVERSION$under$VERSION/debian/compat
echo "Source: $PGKVERSION
Maintainer: $YOU $EMAIL
Section: misc
Priority: optional
Build-Depends: debhelper (>= 7.0.50~), pkg-config, libgnome-keyring-dev, libpurple-dev
Homepage: https://www.github.com/cmotc/pidgin-gnome-keyring

Package: $PGKVERSION
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: Pidgin-Gnome-Keyring package for Debian. "> $PGKVERSION$under$VERSION/debian/control
cp $PGKVERSION$under$VERSION/deb_copyright $PGKVERSION$under$VERSION/debian/copyright
echo "#!/usr/bin/make -f
%:
	dh \$@">$PGKVERSION$under$VERSION/debian/rules
echo '3.0 (quilt)' > $PGKVERSION$under$VERSION/debian/source/format
cd $PGKVERSION$under$VERSION/ 
rm debian/changelog
dch --create -v $VERSION --package $PGKVERSION
autoreconf -i
./configure
dpkg-source --commit
debuild -us -uc 
pwd
cd ..
rm -rf toxcore-debhelper/$PGKVERSION
mv $PGKVERSION$under$VERSION toxcore-debhelper/$PGKVERSION
rm -rf toxcore-debhelper/$PGKVERSION/debian
mv lib$PGKVERSION*$under$VERSION* toxcore-debhelper/
mv $PGKVERSION$under$VERSION* toxcore-debhelper/
dpkg-sig --sign builder $PGKVERSION$under$VERSION*.deb
dpkg-sig --sign builder $PGKVERSION*$under$VERSION*.deb
cp pidgingnomekeyring-nightly.sh toxcore-debhelper/
cd toxcore-debhelper && gpsf
cd .. 
./updaterepo
