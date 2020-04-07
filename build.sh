#!/usr/bin/bash

# 64 * 0.25, 0.5, etc through 2.0
SIZES=(24 32 48 64 80 96 112 128)

# argv1: hotspot string: left, right, up, down, ul, ur, mid. fallback mid
# argv2: size
# sets vars hotx and hoty
hotspots(){
        if [ $1 == left ]
        then
            let hotx=0
            let hoty=$2/2
        elif [ $1 == right ]
        then
            let hotx=$2
            let hoty=$2/2
        elif [ $1 == up ]
        then
            let hotx=$2/2
            let hoty=0
        elif [ $1 == down ]
        then
            let hotx=$2/2
            let hoty=$2
        elif [ $1 == ul ]
        then
            let hotx=0
            let hoty=0
        elif [ $1 == ur ]
        then
            let hotx=$2
            let hoty=0
        else
            let hotx=$2/2
            let hoty=$hotx
        fi
}


mkifnot(){
    for folder in ${@}
    do
        if [ ! -d $folder ]
        then
            mkdir $folder
        fi
    done
}

# argv1: scene name
# argv2: hotspot string
# argv3: delay ms
# args+: links
genblend(){
    local folder=./working/$1/
    local rawfolder=${folder}frames/
    local sizesfolder=${folder}sizes/
    local xcursorin=${folder}${1}.in
    mkifnot $folder $rawfolder $sizesfolder
    rm ${rawfolder}*.png
    rm ${sizesfolder}*.png

    echo -n > $xcursorin

    blender ./src/cursor.blend --background --scene $1 --render-output $rawfolder --render-anim

    for s in ${SIZES[*]}
    do
        hotspots $2 $s
        for filein in ${rawfolder}*.png
        do
            local fileout=${sizesfolder}${s}px_${filein##*/}
            magick convert $filein -resize ${s}x${s} -quality 15 $fileout &
            echo $s $hotx $hoty $fileout $3 >> $xcursorin
        done
    done

    wait

    xcursorgen $xcursorin ./icons/nier_cursors/nier/$1

    cd ./icons/nier_cursors/cursors/
    for link in ${@:4}
    do
        ln -sf ../nier/$1 ./$link
    done
    cd ../../../
}


mkifnot ./working/ ./icons/ ./icons/nier_cursors/ ./icons/nier_cursors/nier/ ./icons/nier_cursors/cursors

genblend Cursor_UL ul 100 left_ptr arrow default top_left_arrow
genblend Cursor_UR ur 100 right_ptr draft_large draft_small
genblend Cursor_L left 100 sb_left_arrow
genblend Cursor_R right 100 sb_right_arrow
genblend Cursor up 100 sb_up_arrow
genblend Cursor_D down 100 sb_down_arrow
genblend Selector mid 100 text xterm
genblend Selector_H mid 100 vertical-text

genblend Loading_Circle mid 16.67 watch wait
genblend Cursor_Loading ul 16.67 left_ptr_watch progress 08e8e1c95fe2fc01f976f1e063a24ccd 3ecb610c1bf2410f44200f48c40d3599

# inherits Adwaita since that's standard-issue and should be a good fallback
echo """[Icon Theme]
Name=NieR Cursors
Inherits=Adwaita""" > ./icons/nier_cursors/index.theme
