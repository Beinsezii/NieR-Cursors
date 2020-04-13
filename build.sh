#!/usr/bin/bash

# 64 * 0.25, 0.5, etc through 2.0
SIZES=(24 32 48 64 80 96 112 128)

# argv1: number
# argv2: decimals
round() {
    local decis=${2:-0}
    echo $(printf %.${decis}f $(echo "scale=${decis};(((10^${decis})*$1)+0.5)/(10^${decis})" | bc))
}

# argv1: maths
# argv2: scale
math() {
    local scale=${2:-8}
    echo $(echo "scale=${scale};$1" | bc)
}

# argv1: hotspot string: left, right, up, down, ul, ur, mid. fallback mid
# argv2: size
# sets vars hotx and hoty
# POSSIBLE TODO: since I'm using `bc` more liberally now,
# would it be better to take 2 %'s as hotspot X and Y coords?
# Would remove the need for this function all together as that's fairly legible.
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
# argv2: hotspot % X (0.0-1.0)
# argv3: hotspot % Y (0.0-1.0)
# argv4: framerate
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
        local hotx=$(round $(math "$s*$2"))
        local hoty=$(round $(math "$s*$3"))
        for filein in ${rawfolder}*.png
        do
            local fileout=${sizesfolder}${s}px_${filein##*/}
            magick convert $filein -resize ${s}x${s} -quality 15 $fileout &
            local delay=$(round $(math "1000/$4"))
            echo $s $hotx $hoty $fileout $delay >> $xcursorin
        done
    done

    wait

    xcursorgen $xcursorin ./icons/nier_cursors/nier/$1

    cd ./icons/nier_cursors/cursors/
    for link in ${@:5}
    do
        ln -sf ../nier/$1 ./$link
    done
    cd ../../../
}

# argv1:  framerate for animations
# args+: (already rendered) scenes to preview
genpreviews(){
    local output=./previews/
    mkifnot $output

    for x in ${@:2}
    do
        local target=./working/${x}/frames/
        local count=`find $target | grep -c .png`
        if [ $count -eq 1 ]
        then
            cp ${target}/*.png ${output}${x}.png
        elif [ $count -gt 1 ]
        then
            local delay=$(round $(math "100/$1"))
            convert -delay $delay -loop 0 ${target}/*.png ${output}${x}.gif &
        fi
    done
    wait
}


mkifnot ./working/ ./icons/ ./icons/nier_cursors/ ./icons/nier_cursors/nier/ ./icons/nier_cursors/cursors

genblend Cursor_UL 0.0 0.0 1 left_ptr arrow default top_left_arrow &
genblend Cursor_UR 1.0 0.0 1 right_ptr draft_large draft_small &
genblend Cursor_L 0.0 0.5 1 sb_left_arrow &
genblend Cursor_R 1.0 0.5 1 sb_right_arrow &
genblend Cursor 0.5 0.0 1 sb_up_arrow &
genblend Cursor_D 0.5 1.0 1 sb_down_arrow &

genblend Selector 0.5 0.5 1 text xterm &
genblend Selector_H 0.5 0.5 1 vertical-text &

genblend Arrow_Dot 0.5 0.5 1 n-resize top_side &
genblend Arrow_Dot_UR 0.5 0.5 1 ne-resize top_right_corner &
genblend Arrow_Dot_R 0.5 0.5 1 e-resize right_side &
genblend Arrow_Dot_LR 0.5 0.5 1 se-resize bottom_right_corner &
genblend Arrow_Dot_D 0.5 0.5 1 s-resize bottom_side &
genblend Arrow_Dot_LL 0.5 0.5 1 sw-resize bottom_left_corner &
genblend Arrow_Dot_L 0.5 0.5 1 w-resize left_side &
genblend Arrow_Dot_UL 0.5 0.5 1 nw-resize top_left_corner &

genblend Arrows_Dot_UD 0.5 0.5 1 double_arrow ns-resize row-resize sb_v_double_arrow size_ver v_double_arrow 00008160000006810000408080010102 2870a09082c103050810ffdffffe0204 &
genblend Arrows_Dot_LR 0.5 0.5 1 col-resize ew-resize h_double_arrow sb_h_double_arrow size_hor 028006030e0e7ebffc7f7070c0600140 14fef782d02440884392942c11205230 &
genblend Arrows_Dot_ULLR 0.5 0.5 1 bd_double_arrow nwse-resize size_fdiag c7088f0f3e6c8088236ef8e1e3e70000 &
genblend Arrows_Dot_LLUR 0.5 0.5 1 fd_double_arrow nesw-resize size_bdiag fcf1c3c7cd4491d801f1e1c78f100000 &
genblend Arrows_Dot_Full 0.5 0.5 1 move 4498f0e0c1937ffe01fd06f973665830 9081237383d90e509aa00f00170e968f &

genblend Arrow 0.5 0.0 1 top_tee &
genblend Arrow_UR 0.85 0.15 1 ur_angle &
genblend Arrow_R 1.0 0.5 1 right_tee &
genblend Arrow_LR 0.85 0.85 1 lr_angle &
genblend Arrow_D 0.5 1.0 1 bottom_tee &
genblend Arrow_LL 0.15 0.85 1 ll_angle &
genblend Arrow_L 0.0 0.5 1 left_tee &
genblend Arrow_UL 0.15 0.15 1 ul_angle &

genblend Arrows_Full 0.5 0.5 1 all-scroll fleur size_all &

wait

genblend Cursor_Loading 0.0 0.0 60 left_ptr_watch progress 08e8e1c95fe2fc01f976f1e063a24ccd 3ecb610c1bf2410f44200f48c40d3599 &
genblend Loading_Circle 0.5 0.5 60 watch wait &

wait

genpreviews 60 Cursor_UL Selector Loading_Circle Arrows_Dot_UD

# inherits Adwaita since that's standard-issue and should be a good fallback
echo """[Icon Theme]
Name=NieR Cursors
Inherits=Adwaita""" > ./icons/nier_cursors/index.theme
