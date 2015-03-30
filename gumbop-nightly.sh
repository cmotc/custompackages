#! /bin/sh
SOURCEVERSION=$(date +%Y%m%d)
REVISION="-1"
VERSION=$SOURCEVERSION$REVISION
GUMBOVERSION='gumbo-parser'
under='_'
YOU="dmotc"
EMAIL="cmotc@openmailbox.org"
echo "$GUMBOVERSION debian package generation tool"
echo $GUMBOVERSION$under$VERSION
echo "Until further notice, the package versions"
echo "Will correspond to the date that the package"
echo "was compiled."
echo "--------------------------------------------"
echo "Cleaning up after last build"
rm -rf $GUMBOVERSION$under$VERSION
cd $GUMBOVERSION && make distclean
echo "Pulling most recent update from master branch"
#git pull upstream master
git pull origin master
cd ..
echo "Generating Original Tarball as $GUMBOVERSION$under$SOURCEVERSION.orig.tar.gz"
tar -pczf $GUMBOVERSION$under$SOURCEVERSION.orig.tar.gz $GUMBOVERSION
echo "Copying source code and creating debian build directory"
cp -r $GUMBOVERSION $GUMBOVERSION$under$VERSION
mkdir -p $GUMBOVERSION$under$VERSION/debian/source
echo "Populating $GUMBOVERSION$under$VERSION/debian directory with necessary files"
#cp $GUMBOVERSION$under$SOURCEVERSION.orig.tar.gz $GUMBOVERSION$under$VERSION/debian/$GUMBOVERSION$under$SOURCEVERSION.orig.tar.gz
#mkdir -p $GUMBOVERSION$under$VERSION/debian/sodium/usr/ && echo " " > $GUMBOVERSION$under$VERSION/debian/sodium/usr/include
echo "9" > $GUMBOVERSION$under$VERSION/debian/compat
echo "Source: $GUMBOVERSION
Maintainer: $YOU $EMAIL
Section: misc
Priority: optional
Build-Depends: build-essential (>= 11.7), libtool (>= 2.4.2-1.11), autotools-dev (>= 20140911.1), automake (>= 1:1.14.1-4), checkinstall (>= 1.6.2-4), check (>= 0.9.10-6.1), git (>= 1:2.1.3-1), yasm (>= 1.2.0-2), debhelper (>= 9)

Package: $GUMBOVERSION
Architecture: any
Depends: \${shlibs:Depends}, \${misc:Depends}
Description: Gumbo pure C99 HTML Parser by Google

Package: $GUMBOVERSION-dev
Architecture: all
Depends: \${shlibs:Depends}, \${misc:Depends}, twister-core(= $VERSION)
Homepage: https://github.com/google/gumbo-parser
Description: Gumbo pure C99 HTML Parser by Google" > $GUMBOVERSION$under$VERSION/debian/control
cp $GUMBOVERSION$under$VERSION/COPYING $GUMBOVERSION$under$VERSION/debian/copyright
echo "#!/usr/bin/make -f
%:
	dh \$@">$GUMBOVERSION$under$VERSION/debian/rules
echo '3.0 (quilt)' > $GUMBOVERSION$under$VERSION/debian/source/format
cd $GUMBOVERSION$under$VERSION/ 
rm debian/changelog
dch --create -v $VERSION --package $GUMBOVERSION
./autogen.sh
./configure
dpkg-source --commit
debuild -d -us -uc 
pwd
cd ..
rm -rf toxcore-debhelper/$GUMBOVERSION
cp $GUMBOVERSION$under$VERSION toxcore-debhelper/$GUMBOVERSION
rm -rf toxcore-debhelper/$GUMBOVERSION/debian
cp $GUMBOVERSION*$under$VERSION* toxcore-debhelper/
cp $GUMBOVERSION$under$VERSION* toxcore-debhelper/
dpkg-sig -k FFECC302 --sign builder $GUMBOVERSION$under$VERSION*.deb
dpkg-sig -k FFECC302 --sign builder $GUMBOVERSION*$under$VERSION*.deb
cp gumbop-nightly.sh toxcore-debhelper/
cd toxcore-debhelper && gpsf
cd .. 
./updaterepo
