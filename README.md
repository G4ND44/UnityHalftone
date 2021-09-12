# UnityHalftone
Unity Halftone postprocess with compute shaders and dynamic procedural geometry.
It uses  Graphics.DrawProcedural and compute shader to modify geometry on the run
![preview](https://i.imgur.com/3kCyIze.gif)![preview2](https://i.imgur.com/dHc2vTg.gif)

It works by adding Halftone Controller on game camera

![inspect](https://i.imgur.com/yNYoFOh.png)

It olso have example of recreating compute shader data via expression. It uses modified template becouse there was no way to get around UnityToClipPos in all templates. Should not be issue with normal use cases (modified template not in project, but you shuold be able to get used expression)
![ase](https://i.imgur.com/jY8ykL4.png)
