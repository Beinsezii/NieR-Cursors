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

    blender ./src/cursor.blend --background --scene $1 --render-output $rawfolder --render-anim &>/dev/null

    for s in ${SIZES[*]}
    do
        local hotx=$(round $(math "$s*$2"))
        local hoty=$(round $(math "$s*$3"))
        for filein in ${rawfolder}*.png
        do
            local fileout=${sizesfolder}$(printf "%03d" $s)px_${filein##*/}
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

# argv1: framerate
# argv+: scenes
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
            convert -dispose Background -delay $delay -loop 0 -define webp:lossless=true ${target}/*.png ${output}${x}.webp &
        fi
    done
    wait
}

# argv1: scene name
# argv2: hotspot % X (0.0-1.0)
# argv3: hotspot % Y (0.0-1.0)
# argv4: framerate
# argv5: windows cursor name
genwindows(){
    local folder=./working/$1/
    local rawfolder=${folder}frames/
    local sizesfolder=${folder}sizes/

    local frames=(${rawfolder}*.png)
    local curfolder=icons/nier_cursors_windows/

    mkifnot $curfolder

    if [ ${#frames[@]} -gt 1 ]
    then
        echo .ani TODO. Falling back to .cur
        magick convert ${sizesfolder}/*${frames[0]##*/} ico:- | ./icotocur.py $2 $3 > ${curfolder}/${5}.cur
    else
        magick convert ${sizesfolder}/*${frames[0]##*/} ico:- | ./icotocur.py $2 $3 > ${curfolder}/${5}.cur
    fi
}


mkifnot ./working/ ./icons/ ./icons/nier_cursors/ ./icons/nier_cursors/nier/ ./icons/nier_cursors/cursors


# cursor corner, inverted
cc=0.05
cci=$(math "1-$cc")

genblend Cursor_UL $cc $cc 1 left_ptr arrow default top_left_arrow &
genblend Cursor_UR $cci $cc 1 right_ptr draft_large draft_small &
genblend Cursor_L $cc 0.5 1 sb_left_arrow &
genblend Cursor_R $cci 0.5 1 sb_right_arrow &
genblend Cursor 0.5 $cc 1 sb_up_arrow &
genblend Cursor_D 0.5 $cci 1 sb_down_arrow &

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
genblend Arrows_Dot_Full 0.5 0.5 1 all-scroll fleur size_all &

# arrow polar and corner [inverted]
ap=0.05
api=$(math "1-$ap")
ac=0.15
aci=$(math "1-$ac")

genblend Arrow 0.5 $ap 1 top_tee &
genblend Arrow_UR $aci $ac 1 ur_angle &
genblend Arrow_R $api 0.5 1 right_tee &
genblend Arrow_LR $aci $aci 1 lr_angle &
genblend Arrow_D 0.5 $api 1 bottom_tee &
genblend Arrow_LL $ac $aci 1 ll_angle &
genblend Arrow_L $ap 0.5 1 left_tee &
genblend Arrow_UL $ac $ac 1 ul_angle &

genblend Arrows_Full 0.5 0.5 1 move 4498f0e0c1937ffe01fd06f973665830 9081237383d90e509aa00f00170e968f &

genblend Hand 0.5 0.1 1 hand1 grab &
genblend Hand_Point 0.375 0.1 1 hand hand2 pointer 9d800788f1b08800ae810202380a0822 e29285e634086352946a0e7090d73106 &
genblend Hand_Grab 0.5 0.5 1 grabbing dnd-none &

genblend Crosshair 0.5 0.5 1 cross crosshair cross_reverse diamond_cross \
    tcross cell &
genblend Targeter 0.5 0.5675 1 dotbox dot_box_mask icon target &

genblend Cursor_Help $cc $cc 1 question_arrow help left_ptr_help 5c6cd98b3f3ebcb1f9c7f1c204630408 d9ce0ab605698f320427677b458ad60b &

wait

genblend Cursor_Loading $cc $cc 60 left_ptr_watch progress 08e8e1c95fe2fc01f976f1e063a24ccd 3ecb610c1bf2410f44200f48c40d3599 &
genblend Loading_Circle 0.5 0.5 60 watch wait &
genblend Cursor_Error $cc $cc 8 crossed_circle not-allowed 03b6e0fcb3499374a867c041f52298f0 &

wait

genpreviews 60 Cursor_UL Selector Loading_Circle Arrows_Dot_UD Hand_Point Crosshair Targeter
genpreviews 8 Cursor_Error

# inherits Adwaita since that's standard-issue and should be a good fallback
echo """[Icon Theme]
Name=NieR Cursors
Inherits=Adwaita""" > ./icons/nier_cursors/index.theme

# Windows
genwindows Cursor_UL $cc $cc 1 normal-select &
genwindows Cursor 0.5 $cc 1 alt-select &
genwindows Cursor_Error $cc $cc 8 unavailable &
genwindows Loading_Circle 0.5 0.5 60 busy &
genwindows Cursor_Loading $cc $cc 60 working-in-background &
genwindows Selector 0.5 0.5 1 text-select &
genwindows Arrows_Dot_Full 0.5 0.5 1 move &
genwindows Arrows_Dot_ULLR 0.5 0.5 1 diagonal-resize-1 &
genwindows Arrows_Dot_LLUR 0.5 0.5 1 diagonal-resize-2 &
genwindows Arrows_Dot_UD 0.5 0.5 1 vertical-resize &
genwindows Arrows_Dot_LR 0.5 0.5 1 horizontal-resize &
genwindows Hand_Point 0.375 0.1 1 link-select &
genwindows Crosshair 0.5 0.5 1 precision-select &
genwindows Cursor_Help $cc $cc 1 help-select &

echo '; Incomplete. Based on Capitaine Cursors install.inf

[Version]
signature="$CHICAGO$"

[DefaultInstall]
CopyFiles = Scheme.Cur, Scheme.Txt
AddReg    = Scheme.Reg

[DestinationDirs]
Scheme.Cur = 10,"%CUR_DIR%"
Scheme.Txt = 10,"%CUR_DIR%"

[Scheme.Reg]
HKCU,"Control Panel\Cursors\Schemes","%SCHEME_NAME%",,"%10%\%CUR_DIR%\%pointer%,%10%\%CUR_DIR%\%help%,%10%\%CUR_DIR%\%work%,%10%\%CUR_DIR%\%busy%,%10%\%CUR_DIR%\%cross%,%10%\%CUR_DIR%\%Text%,%10%\%CUR_DIR%\%Hand%,%10%\%CUR_DIR%\%unavailiable%,%10%\%CUR_DIR%\%Vert%,%10%\%CUR_DIR%\%Horz%,%10%\%CUR_DIR%\%Dgn1%,%10%\%CUR_DIR%\%Dgn2%,%10%\%CUR_DIR%\%move%,%10%\%CUR_DIR%\%alternate%,%10%\%CUR_DIR%\%link%"

; -- Installed files

[Scheme.Cur]
busy.cur
working-in-background.cur
normal-select.cur
help-select.cur
link-select.cur
move.cur
diagonal-resize-2.cur
Install.inf
vertical-resize.cur
horizontal-resize.cur
diagonal-resize-1.cur
handwriting.cur
precision-select.cur
text-select.cur
unavailable.cur
alt-select.cur

[Strings]
CUR_DIR       = "Cursors\NieR Cursors"
SCHEME_NAME   = "NieR Cursors"
pointer       = "normal-select.cur"
help          = "help-select.cur"
work          = "working-in-background.cur"
busy          = "busy.cur"
text          = "text-select.cur"
unavailiable  = "unavailable.cur"
vert          = "vertical-resize.cur"
horz          = "horizontal-resize.cur"
dgn1          = "diagonal-resize-1.cur"
dgn2          = "diagonal-resize-2.cur"
move          = "move.cur"
link          = "link-select.cur"
cross         = "precision-select.cur"
hand          = "handwriting.cur"
alternate     = "alt-select.cur"' > ./icons/nier_cursors_windows/install.inf

wait

echo Done.
