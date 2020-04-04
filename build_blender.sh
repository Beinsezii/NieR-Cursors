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

#argv1: cursor name
#argv+: links
genlinks(){
    xcursorgen ./working/working.in ./icons/nier_cursors/nier/$1

    cd ./icons/nier_cursors/cursors/
    for link in ${@:2}
    do
        ln -sf ../nier/$1 ./$link
    done
    cd ../../../
}

# argv1: scene name
# argv2: hotspot string
# argv3: delay ms
# args+: links
genblend(){
    echo -n > ./working/working.in

    blender ./src/cursor.blend --background --scene $1 --render-output ./src/__frames/ --render-anim

    for s in ${SIZES[*]}
    do
        hotspots $2 $s
        for file in ./src/__frames/*
        do
            magick convert $file -resize ${s}x${s} ./working/${1}_${s}_${file##*/} &
            echo $s $hotx $hoty ./working/${1}_${s}_${file##*/} $3 >> ./working/working.in
        done
    done

    wait

    rm ./src/__frames/*

    genlinks $1 ${@:4}
}


# argv1: folder
# argv2: hotspot
# argv3: delay in ms
# argv+: links
# runs the `animate` script present in the folder with the size as an arg.
# script should produce folder called '__frames' filled with sorted png frames
# of animation for the given size. frames are named and moved to /working and processed like usual
# genanim() {
#     echo -n > ./working/working.in

#     for s in ${SIZES[*]}
#     do
#         hotspots $2 $s
#         cd ./src/$1/
#         ./animate $s
#         cd ../../
#         for file in ./src/$1/__frames/*
#         do
#             mv $file ./working/$1\_$s\_${file##*/}
#             echo $s $hotx $hoty ./working/$1\_$s\_${file##*/} $3 >> ./working/working.in
#         done
#     done

#     genlinks $1 ${@:4}
# }


for folder in ./working/ ./icons/ ./icons/nier_cursors/ ./icons/nier_cursors/nier/ ./icons/nier_cursors/cursors
do
    if [ ! -d $folder ]
    then
        mkdir $folder
    fi
done

genblend Cursor_UL ul 100 left_ptr arrow default top_left_arrow
genblend Cursor_UR ur 100 right_ptr draft_large draft_small
genblend Cursor_L left 100 sb_left_arrow
genblend Cursor_R right 100 sb_right_arrow
genblend Cursor up 100 sb_up_arrow
genblend Cursor_D down 100 sb_down_arrow

# genanim loading_circle mid 30 watch wait
# genanim cursor_loading ul 30 left_ptr_watch progress 08e8e1c95fe2fc01f976f1e063a24ccd 3ecb610c1bf2410f44200f48c40d3599

# inherits Adwaita since that's standard-issue and should be a good fallback
echo """[Icon Theme]
Name=NieR Cursors
Inherits=Adwaita""" > ./icons/nier_cursors/index.theme
