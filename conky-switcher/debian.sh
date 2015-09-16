#! /bin/sh
# Configure your paths and filenames
SOURCEBINPATH=.
SOURCEBIN=conkyswitcher
SOURCEDOC=README.md
DEBFOLDER=../conkyswitcher
DEBVERSION=0.1

git pull origin master

DEBFOLDERNAME=$DEBFOLDER-$DEBVERSION

rm -rf $DEBFOLDERNAME
# Create your scripts source dir
mkdir $DEBFOLDERNAME

# Copy your script to the source dir
cp -R $SOURCEBINPATH/ $DEBFOLDERNAME/
cd $DEBFOLDERNAME
cp conkyswitcher.sh $SOURCEBIN
# Create the packaging skeleton (debian/*)
dh_make -s --indep --createorig 

#mkdir -p debian/tmp/contrib
#cp -R contrib debian/tmp/contrib

# Remove make calls
grep -v makefile debian/rules > debian/rules.new 
mv debian/rules.new debian/rules 

# debian/install must contain the list of scripts to install 
# as well as the target directory
echo $SOURCEBIN usr/bin > debian/install 
#echo "contrib/etc/init.d/$SOURCEBIN" etc/init.d >> debian/install 
#echo "contrib/lib/systemd/system/$SOURCEBIN.service" lib/systemd/system  >> debian/install 
#echo $SOURCEDOC usr/share/doc/toxbot >> debian/install

# Remove the example files
rm debian/*.ex

# Build the package.
# You  will get a lot of warnings and ../somescripts_0.1-1_i386.deb
debuild -us -uc > ../log 