# NieR Style Cursors
Uses Blender 2.82+, xcursorgen, imagemagick, and of course common bash tools like `bc` and probably more.
*Possibly* runs on blender versions as old as 2.80
## Preview Images
renditions updated when you run ./build.sh before committing.
idk how thisll look online maybe it should be one big image don't feel like writing the code to make an imagemagick grid right now.

---
<div class="row">
<img width="64" src="./previews/Cursor_UL.png" />
<img width="64" src="./previews/Selector.png" />
<img width="64" src="./previews/Loading_Circle.gif" />
<img width="64" src="./previews/Arrows_Dot_UD.png" />
</div>

## "Cool how do I yes?"

1. have the tools installed
2. download the thing
3. run the `build.sh` file
4. a folder will appear called 'icons' that has the theme inside. up to your distro gods what to do with the generated theme.

## Cursors included in theme so far
### Adwaita is a fallback for those not included. This can be changed in the "index.theme" file present in the built theme.
- arrow -> Cursor_UL
- default -> Cursor_UL
- draft_large -> Cursor_UR
- draft_small -> Cursor_UR
- left_ptr -> Cursor_UL
- left_ptr_watch -> Cursor_Loading
- progress -> Cursor_Loading
- right_ptr -> Cursor_UR
- sb_down_arrow -> Cursor_D
- sb_left_arrow -> Cursor_L
- sb_right_arrow -> Cursor_R
- sb_up_arrow -> Cursor
- text -> Selector
- top_left_arrow -> Cursor_UL
- vertical-text -> Selector_H
- wait -> Loading_Circle
- watch -> Loading_Circle
- xterm -> Selector
- - plus the appropriate gibberish-string ones

## F.A.Q.
Question|Answer
---|---
Why does .build.sh take years?|60fps animations. Smoother than a well-oiled Adam. When this pack actually has more cursors than I have digits and assuming I'm not alone in the world, I *might* upload premade packs. Maybe I should do it anyway since I've never used the 'attach-file-to-tag' feature on github and it'd probably be handy to know.
What is this licensed under?|IDK whatever doesn't get me sue by squeenix. CC0 if possible; I just make stuff cause I wanna.
Some cursors look 'off'. Ex: Default arrow.|They're mathematically perfect, not optically/perceptually perfect. Accounting for the distortion of dumb human brains takes more effort than I'm willing to put in right now.
Why Blender? Inkscape or Illustrator would do this and that and everything better|Inkscape 0.9X straight doesn't support the cursor workflow of sharing assets and non-destructive modification. Inkscape 1.0 beta *does* but also eats my fukken soul every time it crashes or hangs, which is a lot. So much so that if I had $100 for every time I lost changes in Inkscape beta I would be well on my way to taking that computer science class I can't afford. Ergo, Illustrator is also out of the picture cause expensive proprietary biz. Blender with it's new Eevee render is a swiss army knife of artwork and has only crashed like 4 times so far so overall it has a Crash-Per-Session (CPS)[not related] rate improvement of a few thousand percent over Inkscape beta. There's an unmaintained Inkscape branch in this git repo if you *still* don't believe me, where I initially made the cursor and loading circle.
