#! /bin/sh

REPO_ARRAY=0

CONFIG_FILE="#!/bin/sh
CONFIG_DIR=\$HOME/.config/conkyswitcher
"
if [ -f "$HOME/.config/conkyswitcher/rcconfig" ]; then
	. $HOME/.config/conkyswitcher/rcconfig
else
	if [ -d "$HOME/.config/conkyswitcher" ]; then
		echo $CONFIG_FILE > $HOME/.config/conkyswitcher/rcconfig
		. $HOME/.config/conkyswitcher/rcconfig
	else
		mkdir -p "$HOME/.config/conkyswitcher"
		echo $CONFIG_FILE > $HOME/.config/conkyswitcher/rcconfig
		. $HOME/.config/conkyswitcher/rcconfig
	fi
fi


rm -rf packages/*

cslistcompute(){
	cat $CONFIG_DIR/conkyrc.list $CONFIG_DIR/conkyrc.list.d/*.list > $CONFIG_DIR/.generated_list
	unset REPO_ARRAY
	while read line; do
		REPO_ARRAY+=($line)
	done < .generated_list
	rm $CONFIG_DIR/.generated_list
	printf '%s\n' "${REPO_ARRAY[@]}"
}

cspullpkgs(){
	cd $CONFIG_DIR/packages/
	for i in "${REPO_ARRAY[@]}"; do
		wget $i 
	done
	cd ../
}

CS_ZIP_EXT=""

cscheckexists(){
	myarray=(`find ./ -maxdepth 1 -name "$CS_ZIP_EXT"`)
	if [ ${#myarray[@]} -gt 0 ]; then 
		unset CS_ZIP_EXT
		return 1 
	else
		unset CS_ZIP_EXT
		return 0
	fi
}

csunzippkgs(){
	cd $CONFIG_DIR/packages/
	CS_ZIP_EXT="*.gz"
	if [[ $(cscheckexists; echo $?) -eq 1 ]]; then
		for i in *.gz; do
#			tmp=${"$i"%.*}
#			mkdir $tmp
			gunzip -vf $i
#			mv 
		done
	fi
	CS_ZIP_EXT="*tar.gz"
	if [[ $(cscheckexists; echo $?) -eq 1 ]]; then
		for i in *.tar.gz; do
			tar -xzvf $i
		done
	fi
	CS_ZIP_EXT="*.zip"
	if [[ $(cscheckexists; echo $?) -eq 1 ]]; then
		for i in *.zip; do
			unzip -ovu $i
		done
	fi
	unset CS_ZIP_EXT
	cd ..
}

csupdate(){
	cslistcompute
	cspullpkgs
	csunzippkgs
}

csswitch(){
	echo " Switching to $1"
	CS_WD=$CONFIG_DIR
	SWITCH_TO="$CS_WD/packages/$1"
	CONKY_FILE=$HOME/.conkyrc
	rm $CONKY_FILE
	echo $SWITCH_TO
	echo $CONKY_FILE
	ln -s $SWITCH_TO $CONKY_FILE
	killall conky
	conky &
}

csinfo(){
	ls $CONFIG_DIR/packages/
}

csprint(){
	CS_WD=$CONFIG_DIR
	SWITCH_TO="$CS_WD/packages/$1"
	cat $SWITCH_TO
}

csinstall(){
	sudo cp conkyswitcher.sh /usr/bin/conkyswitcher
	sudo chmod a+x /usr/bin/conkyswitcher
	echo "
		. /usr/bin/conkyswitcher
	" >> $HOME/.profile
}