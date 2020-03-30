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

# argv1: svg name
# argv2: hotspot string
# args+: links
# so `genstatic cursor_left ul arrow default` will
# link the x cursors 'arrow' and 'default' with the
# export of cursor_left.svg and a hotspot in the upper-left
genstatic(){
    echo -n > ./working/working.in

    for s in ${SIZES[*]}
    do
        inkscape -w $s -h $s ./src/$1.svg -o ./working/$1_$s.png &
    done

    wait

    for s in ${SIZES[*]}
    do
        hotspots $2 $s
        echo $s $hotx $hoty ./working/$1\_$s.png 100 >> ./working/working.in
    done

    genlinks $1 ${@:3}
}


# argv1: folder
# argv2: hotspot
# argv3: delay in ms
# argv+: links
# runs the `animate` script present in the folder with the size as an arg.
# script should produce folder called '__frames' filled with sorted png frames
# of animation for the given size. frames are named and moved to /working and processed like usual
genanim() {
    echo -n > ./working/working.in

    for s in ${SIZES[*]}
    do
        hotspots $2 $s
        ./src/$1/animate $s
        for file in ./src/$1/__frames/*
        do
            mv $file ./working/$1\_$s\_${file##*/}
            echo $s $hotx $hoty ./working/$1\_$s\_${file##*/} $3 >> ./working/working.in
        done
    done

    genlinks $1 ${@:4}
}


for folder in ./working/ ./icons/ ./icons/nier_cursors/ ./icons/nier_cursors/nier/ ./icons/nier_cursors/cursors
do
    if [ ! -d $folder ]
    then
        mkdir $folder
    fi
done

genstatic cursor_ul ul left_ptr arrow default top_left_arrow
genstatic cursor_ur ur right_ptr draft_large draft_small
genstatic cursor_left left sb_left_arrow
genstatic cursor_right right sb_right_arrow
genstatic cursor up sb_up_arrow
genstatic cursor_down down sb_down_arrow

genanim loading_circle mid 30 watch wait

# inherits Adwaita since that's standard-issue and should be a good fallback
echo """[Icon Theme]
Name=NieR Cursors
Inherits=Adwaita""" > ./icons/nier_cursors/index.theme
