#! /usr/bin/env bash

# Signature
# scene_name windows_name delay hotx hoty
scene_name=$1
windows_name=$2
delay=$3
hotx=$4
hoty=$5

images=(./working/$1/frames/*.png)
first=${images[0]}
unset images[0]

pycode="
try:
    img = Gimp.list_images()[0]

    loaded_layers = [Gimp.file_load_layer(1, img, Gio.file_new_for_path(i)) for i in '${images[@]}'.split(' ')]
    for lay in loaded_layers:
        img.insert_layer(lay, None, 0)

    layers = img.list_layers()
    size = len(layers)

    c = Gimp.get_pdb().lookup_procedure('file-ani-save').create_config()
    c.set_property('image', img)
    c.set_property('file', Gio.file_new_for_path('./icons/nier_cursors_windows/$windows_name.ani'))
    c.set_property('drawables', Gimp.ObjectArray.new(Gimp.Drawable, layers, False))
    c.set_property('num-drawables', size)
    c.set_property('author-name', 'Beinsezii')
    c.set_property('cursor-name', 'NieR_$name')
    c.set_property('default-delay', $delay)
    c.set_property('n-hot-spot-x', size)
    c.set_property('n-hot-spot-y', size)

    # TODO figure out how to construct a Gimp.Int32Array
    # has no constructor
    # doesn't like python lists, Gimp.Array, or Gimp.ValueArray
    # the fuck do I do. introspection why you do dis

    # c.set_property('hot-spot-x', [$hotx] * size)
    # c.set_property('hot-spot-y', [$hoty] * size)

    Gimp.get_pdb().run_procedure_config('file-ani-save', c)

except Exception as e:
    print(f'BEGIN_GIMP_ANI_ERROR\n\n\n{e}\n\n\nEND_GIMP_ANI_ERROR')
"

gimp-2.99 --batch-interpreter python-fu-eval --quit -idfb "$pycode" $first
