#! /bin/sh

REPO_ARRAY=0

rm -rf packages/*

cslistcompute(){
	cat ./conkyrc.list ./conkyrc.list.d/*.list > ./.generated_list
	unset REPO_ARRAY
	while read line; do
		REPO_ARRAY+=($line)
	done < .generated_list
	rm ./.generated_list
	printf '%s\n' "${REPO_ARRAY[@]}"
}

cspullpkgs(){
	cd ./packages/
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
	cd ./packages/
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
	CS_WD=$(pwd)
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
	ls ./packages/
}

csprint(){
	CS_WD=$(pwd)
	SWITCH_TO="$CS_WD/packages/$1"
	cat $SWITCH_TO
}

