#!/usr/bin/bash

# 64 * 0.25, 0.5, etc through 2.0
# TODO make more customizable or something idk maybe this is a python job
SIZES=(24 32 48 64 80 96 112 128)
# argv1: svg name
# argv2: hotspot. ul (uppperleft), up, ur, mid. fallback mid
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
        if [ $2 == ul ]
        then
            hotx=0
            hoty=0
        elif [ $2 == up ]
        then
            let hotx=$s/2
            hoty=0
        elif [ $2 == ur ]
        then
            hotx=$s
            hoty=0
        else
            let hotx=$s/2
            hoty=$hotx
        fi

        echo $s $hotx $hoty ./working/$1\_$s.png 100 >> ./working/working.in
    done

    xcursorgen ./working/working.in ./icons/nier_cursors/nier/$1

    cd ./icons/nier_cursors/cursors/
    for link in ${@:3}
    do
        ln -sf ../nier/$1 ./$link
    done
    cd ../../../

}

#same syntax as genstatic(), but looks for a folder of svgs to make an animtion
genanim() {
    echo -n > ./working/working.in

    for s in ${SIZES[*]}
    do

        if [ $2 == ul ]
        then
            hotx=0
            hoty=0
        elif [ $2 == up ]
        then
            let hotx=$s/2
            hoty=0
        elif [ $2 == ur ]
        then
            hotx=$s
            hoty=0
        else
            let hotx=$s/2
            hoty=$hotx
        fi

        ./src/$1/animate $s
        for file in ./src/$1/__frames/*
        do
            mv $file ./working/$1\_$s\_${file##*/}
            echo $s $hotx $hoty ./working/$1\_$s\_${file##*/} $3 >> ./working/working.in
        done
    done

    xcursorgen ./working/working.in ./icons/nier_cursors/nier/$1

    cd ./icons/nier_cursors/cursors/
    for link in ${@:4}
    do
        ln -sf ../nier/$1 ./$link
    done
    cd ../../../
}


for folder in ./working/ ./icons/ ./icons/nier_cursors/ ./icons/nier_cursors/nier/ ./icons/nier_cursors/cursors
do
    if [ ! -d $folder ]
    then
        mkdir $folder
    fi
done

genstatic cursor_left ul left_ptr arrow default top_left_arrow
genstatic cursor_right ur right_ptr draft_large draft_small
genanim loading mid 30 watch wait

# inherits Adwaita since that's standard-issue and should be a good fallback
echo """[Icon Theme]
Name=NieR Cursors
Inherits=Adwaita""" > ./icons/nier_cursors/index.theme
