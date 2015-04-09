#! /bin/sh
SOURCEVERSION=$(date +%Y%m%d)
REVISION="-1"
VERSION=$SOURCEVERSION$REVISION
IIPVERSION='i2p.i2p'
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
Section: net
Priority: optional
Build-Depends: build-essential (>= 11.7), ant (>= 1.8), ant-optional, debconf, default-jdk | openjdk-7-jdk | openjdk-6-jdk, dh-apparmor, gettext, libgmp3-dev, libcommonslogging-java, hardening-wrapper, po-debconf, debhelper (>= 9)

Package: $IIPVERSION
Architecture: any
Section: net
Priority: optional
Depends: \${java:Depends}, \${shlibs:Depends},
 adduser,
 i2p-router (>= 0.8.6-5),
 libjbigi-jni,
 lsb-base,
 service-wrapper
Description: i2p Java package for Anonymous, Peer-To-Peer post-internet networking.

Package: $IIPVERSION-dev
Architecture: all
Section: net
Priority: optional
Depends: \${shlibs:Depends}, \${misc:Depends}, $IIPVERSION(= $VERSION)
Homepage: https://github.com/i2p/i2p.i2p
Description: i2p Java package for Anonymous, Peer-To-Peer post-internet networking.

Package: libjbigi-jni
Architecture: any
Section: java
Priority: optional
Depends: \${shlibs:Depends}, i2p-router
Homepage: http://www.i2p2.de/jbigi
Description: Java Big Integer library
 This Package contains the libjbigi JNI library (and on x86 platforms, jcpuid).
 .
 libjbigi is a math library that is part of the I2P installation.  Use of this
 library greatly enhances the efficiency of cryptographic algorithms, such as
 the ones used by I2P. You can expect to see a 5-7x speed improvement on certain
 tasks, such as elGamal encryption/decryption.

Package: $IIPVERSION-doc
Architecture: all
Section: doc
Depends: \${misc:Depends}
Suggests: i2p, default-jdk-doc
Description: Documentation for I2P
 I2P is an anonymizing network, offering a simple layer that identity-sensitive
 applications can use to securely communicate. All data is wrapped with several
 layers of encryption, and the network is both distributed and dynamic, with no
 trusted parties.
 .
 This package contains the Javadoc files.

Package: $IIPVERSION-router
Architecture: all
Section: net
Priority: optional
Depends: \${misc:Depends}, \${java:Depends}, \${shlibs:Depends},
 openjdk-8-jre-headless | openjdk-7-jre-headless | openjdk-6-jre-headless | default-jre-headless | java8-runtime-headless | java7-runtime-headless | java6-runtime-headless, libecj-java
Replaces: i2p ( << 0.8.6-5)
Breaks: i2p (<< 0.8.6-5)
Recommends: libjbigi-jni, ttf-dejavu
Suggests: tor, i2p-messenger, i2phex, i2p-tahoe-lafs, imule, irc-client, itoopie, mail-client, mail-reader, news-reader, polipo, privoxy, robert, syndie, www-browser, xul-ext-torbutton
Description: Load-balanced unspoofable packet switching network
 I2P is an anonymizing network, offering a simple layer that identity-sensitive
 applications can use to securely communicate. All data is wrapped with several
 layers of encryption, and the network is both distributed and dynamic, with no
 trusted parties.
 .
 TrueType fonts (such as those provided in the package ttf-dejavu) are required
 in order to generate graphs.
" > $IIPVERSION$under$VERSION/debian/control
cp $IIPVERSION$under$VERSION/COPYING $IIPVERSION$under$VERSION/debian/copyright
echo "#!/usr/bin/make -f
%:
	dh \$@">$IIPVERSION$under$VERSION/debian/rules
echo '3.0 (quilt)' > $IIPVERSION$under$VERSION/debian/source/format
cd $IIPVERSION$under$VERSION/ 
rm debian/changelog
dch --create -v $VERSION --package $IIPVERSION
#./bootstrap.sh
#./configure #--enable-av
dpkg-source --commit
debuild -d -us -uc 
pwd
cd ..
rm -rf toxcore-debhelper/$IIPVERSION
dpkg-sig -k C62339BC --sign builder $IIPVERSION$under$VERSION*.deb
dpkg-sig -k C62339BC --sign builder $IIPVERSION*$under$VERSION*.deb
mv $IIPVERSION$under$VERSION toxcore-debhelper/$IIPVERSION
mv $IIPVERSION*$under$VERSION* toxcore-debhelper/
mv $IIPVERSION$under$VERSION* toxcore-debhelper/
cp i2p-nightly.sh toxcore-debhelper/
