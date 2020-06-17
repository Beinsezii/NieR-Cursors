#!/usr/bin/bash

printf -v date '%(%Y-%m-%d)T'

git tag ${date}

cd icons/
zip -q ../NieR_Cursors_Windows_${date}.zip nier_cursors_windows/*
tar -caf ../NieR_Cursors_${date}.tar.xz nier_cursors
