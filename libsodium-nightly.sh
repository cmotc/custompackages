SOURCEVERSION='1.0.1' #$(date +%Y%m%d)
REVISION="-1"
VERSION=$SOURCEVERSION$REVISION
SODIUM='sodium'
under='_'
YOU="dmotc"
EMAIL="cmotc@openmailbox.org"
echo "$SODIUM debian package generation tool"
echo $SODIUM$under$VERSION
echo "Until further notice, the package versions"
echo "must be changed manually to correspond with"
echo "the master branch."
echo "WIP Automatically returning current version"
echo "--------------------------------------------"
echo "Cleaning up after last build"
rm -rf $SODIUM$under$VERSION
cd $SODIUM && make distclean
echo "Pulling most recent update from master branch"
git fetch upstream
git pull
cd ..
echo "Generating Original Tarball as $SODIUM$under$SOURCEVERSION.orig.tar.gz"
tar -pczf $SODIUM$under$SOURCEVERSION.orig.tar.gz "$SODIUM"
echo "Copying source code and creating debian build directory"
cp -r $SODIUM $SODIUM$under$VERSION
mkdir -p $SODIUM$under$VERSION/debian/source
echo "Populating $SODIUM$under$VERSION/debian directory with necessary files"
#cp $SODIUM$under$SOURCEVERSION.orig.tar.gz $SODIUM$under$VERSION/debian/$SODIUM$under$SOURCEVERSION.orig.tar.gz
echo "8" > $SODIUM$under$VERSION/debian/compat
echo "Source:$SODIUM
Maintainer: $YOU $EMAIL
Section: misc
Priority: optional
Standards-Version: 3.9.2
Build-Depends: debhelper (>= 8), devscripts, build-essential

Package: lib$SODIUM
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Homepage: https://libsodium.org
Description: libsodium

Package: lib$SODIUM-dev
Architecture: all
Depends: \${shlibs:Depends}, \${misc:Depends}, libsodium(= $VERSION)
Homepage: https://libsodium.org
Description: libsodium development files" > $SODIUM$under$VERSION/debian/control
cp $SODIUM$under$VERSION/LICENSE $SODIUM$under$VERSION/debian/copyright
echo "#!/usr/bin/make -f
%:
	dh \$@">$SODIUM$under$VERSION/debian/rules
echo '3.0 (quilt)' > $SODIUM$under$VERSION/debian/source/format
cd $SODIUM$under$VERSION/
pwd
rm debian/changelog
dch --create -v $VERSION --package $SODIUM ""
autoreconf -i
./configure
dpkg-source --commit
debuild -us -uc 
cd ..
rm -rf toxcore-debhelper/$SODIUM
dpkg-sig -k C62339BC --sign builder lib$SODIUM$under$VERSION*.deb
dpkg-sig -k C62339BC --sign builder lib$SODIUM*$under$VERSION*.deb
mv $SODIUM$under$VERSION* toxcore-debhelper/$SODIUM
mv lib$SODIUM$under$VERSION* toxcore-debhelper/
mv lib$SODIUM*$under$VERSION* toxcore-debhelper/
mv *.orig.tar.gz toxcore-debhelper/
cp libsodium-nightly.sh toxcore-debhelper/
cd toxcore-debhelper && ./gpsf
cd ..
./updaterepo