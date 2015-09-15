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
. ./libtoxcore-debfiles.sh
cd $TOXVERSION$under$VERSION/ 
rm debian/changelog
dch --create -v $VERSION --package $TOXVERSION
./autogen.sh
./configure --enable-av
dpkg-source --commit
debuild -d -us -uc --lintian-opts --no-lintian > ../$TOXVERSION.log
pwd
cd ..
rm -rf toxcore-debhelper/$TOXVERSION
dpkg-sig -k 962D297E --sign builder lib$TOXVERSION$under$VERSION*.deb
dpkg-sig -k 962D297E --sign builder lib$TOXVERSION*$under$VERSION*.deb
mv $TOXVERSION$under$VERSION toxcore-debhelper/$TOXVERSION
mv lib$TOXVERSION*$under$VERSION* toxcore-debhelper/
mv lib$TOXVERSION$under$VERSION* toxcore-debhelper/
mv $TOXVERSION$under$VERSION* toxcore-debhelper/
cp libtoxcore-nightly.sh toxcore-debhelper/
