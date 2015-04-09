#! /bin/sh
SOURCEVERSION=$(date +%Y%m%d)
REVISION="-1"
VERSION=$SOURCEVERSION$REVISION
TWISTVERSION='twister-core'
under='_'
YOU="dmotc"
EMAIL="cmotc@openmailbox.org"
echo "$TWISTVERSION debian package generation tool"
echo $TWISTVERSION$under$VERSION
echo "Until further notice, the package versions"
echo "Will correspond to the date that the package"
echo "was compiled."
echo "--------------------------------------------"
echo "Cleaning up after last build"
rm -rf $TWISTVERSION$under$VERSION
cd $TWISTVERSION && make distclean
echo "Pulling most recent update from master branch"
git fetch upstream master
git pull origin master
#rm -rf libtorrent
#git clone git@github.com:rakshasa/libtorrent.git
git add . && git commit -am "libtorrent"
git push origin master
cd ..
echo "Generating Original Tarball as $TWISTVERSION$under$SOURCEVERSION.orig.tar.gz"
tar -pczf $TWISTVERSION$under$SOURCEVERSION.orig.tar.gz $TWISTVERSION
echo "Copying source code and creating debian build directory"
cp -r $TWISTVERSION $TWISTVERSION$under$VERSION
mkdir -p $TWISTVERSION$under$VERSION/debian/source
echo "Populating $TWISTVERSION$under$VERSION/debian directory with necessary files"
#cp $TWISTVERSION$under$SOURCEVERSION.orig.tar.gz $TWISTVERSION$under$VERSION/debian/$TWISTVERSION$under$SOURCEVERSION.orig.tar.gz
#mkdir -p $TWISTVERSION$under$VERSION/debian/sodium/usr/ && echo " " > $TWISTVERSION$under$VERSION/debian/sodium/usr/include
echo "9" > $TWISTVERSION$under$VERSION/debian/compat
echo "Source: $TWISTVERSION
Maintainer: $YOU $EMAIL
Section: misc
Priority: optional
Build-Depends: build-essential (>= 11.7), libtool (>= 2.4.2-1.11), autotools-dev (>= 20140911.1), automake (>= 1:1.14.1-4), checkinstall (>= 1.6.2-4), check (>= 0.9.10-6.1), git (>= 1:2.1.3-1), yasm (>= 1.2.0-2), debhelper (>= 9), libboost-all-dev (>= 1.55.0.2), libdb++-dev (>= 5.3.0+b1), libminiupnpc-dev (>= 1.9.20140610-2), libssl-dev (>= 1.0.1k-1)

Package: $TWISTVERSION
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: Twister-Core Package for Debian

Package: $TWISTVERSION-dev
Architecture: all
Depends: \${shlibs:Depends}, \${misc:Depends}, twister-core(= $VERSION)
Homepage: https://twister.net.co
Description: Twister Core Library Package for Debian" > $TWISTVERSION$under$VERSION/debian/control
cp $TWISTVERSION$under$VERSION/COPYING $TWISTVERSION$under$VERSION/debian/copyright
echo "#!/usr/bin/make -f
%:
	dh \$@">$TWISTVERSION$under$VERSION/debian/rules
echo '3.0 (quilt)' > $TWISTVERSION$under$VERSION/debian/source/format
cd $TWISTVERSION$under$VERSION/ 
rm debian/changelog
dch --create -v $VERSION --package $TWISTVERSION
./bootstrap.sh
./configure #--enable-av
dpkg-source --commit
debuild -d -us -uc 
pwd
cd ..
rm -rf toxcore-debhelper/$TWISTVERSION
dpkg-sig -k C62339BC --sign builder $TWISTVERSION$under$VERSION*.deb
dpkg-sig -k C62339BC --sign builder $TWISTVERSION*$under$VERSION*.deb
mv $TWISTVERSION$under$VERSION toxcore-debhelper/$TWISTVERSION
mv $TWISTVERSION*$under$VERSION* toxcore-debhelper/
mv $TWISTVERSION$under$VERSION* toxcore-debhelper/
cp twisterd-nightly.sh toxcore-debhelper/