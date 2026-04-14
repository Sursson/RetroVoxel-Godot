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

#### MagicaVoxel workflow
1. Open **[MagicaVoxel](https://ephtracy.github.io/index.html?page=mv_main)**
2. Load your voxel model
3. In the *Export options*, use *Slice*
4. Save the **.png** file
5. Open **Godot**
6. Open your project with the *Retro Voxel package* included
7. Import your *voxel slices .png* file
8. *Import as* ***Image***
9. *Create New → Resource...*
10. Search for *VoxelResource*
12. In the *VoxelResource* add your *voxel image file* as the *Voxel Atlas property*
13. Set the *Sheet* dimensions' *X value* to **1**, and *Y value* to your voxel's **Z depth layer count** <br> <i>Note: To get the correct number, find your model's size and check the value on the Z axis.</i> 
14. Set the *Sprite View* to **"Y Positive"** and *Row Order* to **Bottom To Top**
15. Leave the Pivot Offset as it is right now, you can always change it later!
16. You can continue with the [Voxel Maker setup](#voxel-maker-setup)!

#### Custom workflow _(using any other image editor)_
1. Create your voxel model's slices by creating an image file
2. You only need to follow two three rules:
     1. Set your *background* to be *transparent* and *use full opaque pixels*!
     2. Your image atlas should consist of *tiles with same sizes*! *(Individual tiles can have non-uniform dimensions)*
     3. If you decide to use *multiple columns*, keep in mind that the script will always read each row's tiles from *left to right*!
3. Save the voxel atlas as a **.png** file
4. Open **Godot**
5. Open your project with the *Retro Voxel package* included
6. Import your *voxel atlas .png* file
7. *Import as* ***Image***
8. *Create New → Resource...*
9. Search for *VoxelResource*
10. In the *VoxelResource* add your *voxel image file* as the *Voxel Atlas property*
11. Set the *Sheet* dimensions' *X value* to the number of **columns** *(tiles you made horizontally)*, and *Y value* to the number of **rows** *(tiles you made vertically)*
12. Set the *Sprite View* to your desired axis:
      - Each axis represents in which direction each tile will be drawn
      - Each axis' positive or negative property decides in which order the tiles are drawn
13. Set the *Row Order* depending on *which order* you want the script *to read your rows*
14. Leave the Pivot Offset as it is right now, you can always change it later!
15. You can continue with the [Voxel Maker setup](#voxel-maker-setup)!

#### Voxel Maker setup
1. Under the scenes folder use either b_voxels_template.tscn or c_voxels_template.tscn depending on if you want to create a (b) billboard or (c) cube voxel model. <br> Once you instantiate either into your scene, you will get a ***"Voxel Resource is not set."*** error - **don't mind it yet!**
2. In the *Inspector* find the *Voxel Maker script's* properties and add your **Voxel Resource** to the *script's property*!
3. *Voxel Size* is **1** by default, in some cases it is useful to set the size to a bigger value in the billboard variant.
4. *Voxel Scale* should be set to better match your model size. <br> Note: by default, each voxel is 1 unit large. For example if your voxel model is 32 voxels wide, which should be 1 unit wide in the scene, the voxel scale should be 1/32, so 0.03125
5. *Visibility Padding* is **1** by default. This sets a voxel unit thick border around your model and *sets that boundary as the Visibility AABB*.
6. In the *Editor Visibility Menu* if you click the **On** button for ***View Models***, you will see your voxel model in the Editor, thus you can adjust your Voxel Resource properties easier (for example the pivot offset)! <br> Note: to see your changes, you should turn off and reactivate the View Voxels property!
