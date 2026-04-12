# Retro Voxel (Godot Edition)
<p align=center>
<img width="440" height="210" alt="Retro Voxel Logo" src="https://github.com/user-attachments/assets/2806c038-8371-485a-b6a8-1f0a307e98b6" />
</p>

## What is this?
**Retro Voxel _(Godot Edition)_** is a Godot Project with an included script package that aims to create voxels from an image sheet using Godot's built in Particle System.

## Why?
The initial goal in making this project was to have a way to create a _retro style voxel effect_ for projects that aim for an authentic mid to late 90's game look. <br>
For comparision purposes here are two screenshots from the same game, but almost 30 years apart:
<p align=center>
<img width="1256" height="493" alt="compare1" src="https://github.com/user-attachments/assets/3ded896a-3572-4017-89c9-88996b6c7c74" />
<i>(Left) Blood: Refreshed Supply (2025)&emsp;&emsp;(Right) Blood (1997)</i>
<br />
&nbsp;
<img width="1256" height="493" alt="compare2" src="https://github.com/user-attachments/assets/f8ff3958-47a2-4beb-8c21-e7a2511b630d" />
<i>(Left) Blood: Refreshed Supply (2025)&emsp;&emsp;(Right) Blood (1997)</i>
</p>
<br>

Notice how in the first release in 1997, voxels consisted of *"camera facing" billboards*, while nowadays (as in the 2025 version) voxels are rendered with _"cubes"_. Cubes obviously have their advantages when it comes to 3d rendering (see more below), but Retro Voxel
offers a way to create an authentic, billboard voxel look if that's your vision. <br>

Note that this package comes with examples for both styles!

## How to use it?
Once you pulled this project, you can open it in Godot!

Open `/scenes/voxelTest.tscn` and once you press **Run**, you should see the following:

<p align=center>
  <img width="1156" height="652" alt="2026-04-12 16_03_43-Window" src="https://github.com/user-attachments/assets/f5eb9182-9bf6-4479-9ab0-d8a81f452d7c" />
  <i>From left to right: <b>Truck voxels</b> (Retro, Cube (Unshaded and Shaded)), <b>Monument</b> (Retro), <b>Knight</b> (Retro, Cube (Unshaded and Shaded))</i><br>
  Monument and Knight voxels are made by <i><a href="https://x.com/ephtracy">ephtracy</a></i> and are exported from <b><a href="https://ephtracy.github.io/index.html?page=mv_main">MagicaVoxel</a></b>!
</p>

### FileSystem Guide
```
materials - (materials for cube rendering (mandantory in order to color voxels))
scenes - 
       - b_voxels_template.tscn - "prefab" scene for (b) billboard voxels
       - c_voxels_template.tscn - "prefab" scene for (c) cube voxels
       - voxelTest.tscn - demo scene
scripts -
        - auto_rotate.gd - a simple gdscript to rotate objects for demo scene
        - voxel_maker.gd - voxel creation script that reads pixels from a resource file, and emits particles using the particle system for each pixel
        - voxel_resource.gd - voxel resource that contains image data and options
shaders -
        - voxelShader.gdshader - a simple (default empty) shader that's needed to override particle color data upon emitting
voxels - (example voxels)
       - images - (.png images of voxel slices)
       - objects - (voxel objects stored in voxel resources)
```
### Create new voxel
First you need a .png file of your sliced voxel model! You can make your own in any image editing software *(Photoshop, GIMP, etc.)*, or you can use a voxel creation software *([MagicaVoxel](https://ephtracy.github.io/index.html?page=mv_main))*!

