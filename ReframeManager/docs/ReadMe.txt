Reframe Manager - Application for managing reframe files and proxy editing of GoPro MAX 360 degree video files

0. Introduction

GoPro MAX is a action camera capable of shooting full 360 degree video. The footage can be afterwards reframed to normal high definition video using GoPro Player application on mobile device, windows PC or Mac. The original video is provided in high and low definition fomats which can be handled separatalely in the app. To produce high definition output, the reframing has to be made with the original high definition 360 degree video file, and the application itself doesn't give ability to use the low definition file as proxy. That is: You can't simply reframe the low quality file to produce high quality output.

The high quality 360 degree video file uses HVEC encoding, which at this writing in 2020 support for is missing from even relatively new Macbook Air models of 2017.

New mobile and devices and PC graphics adapters, as well as graphics adapters of the newer Macs have the support of HVEC encoding, so if the users of those systems can simply launch the GoPro Player on highe definition 360 degree video file, do the reframing and render high quality output. The software however doesn't give the ability to make different reframings for the same video: The reframing video is hidden from casual user, and normally the same reframing file is used whenever you open 360 degree video for reframing.

There is workaround for this: The reframing files in the application bundle folder can are interchangable, so one can do reframing for the low resolution 360 degree file and rename the reframe file produced by the softaware as it had been created for the corresponding high definition file. Now when the software is opened for reframing the hig definition footage, the reframing for made for the low resolution opens with it, and high definition output can be rendered.

Example:

After extracting a 360 degree video from the camera, we have three files:

     size date         name
-----------------------------------
128586228 11 Elo 18:27 GS010069.360 <- 360 degree HVEC encoded high definition video
  5575817 11 Elo 18:27 GS010069.LRV <- 360 degree low resolution video
    92163 11 Elo 18:26 GS010069.THM <- Still image preview

If we open LRV and 360 files in GoPro Player and do minimum reframing, creating first keyframe, and look at the bundle directory:

Direcory:
~/Library/Containers/com.gopro.GoPro-Player/Data/Library/Application Support

Reframe-file for the LRV (low resolution) video:
2020-08-11-18-26-58-000+0300-5575817.reframe

Reframe-file for the 360 (high resolution) video:
2020-08-11-18-26-58-000+0300-128586228.reframe

Now we can take the name of the latter, remove the video itself and make a copy of the reframing made for the low resolution:

Remove reframing file for the high definition:
$rm 2020-08-11-18-26-58-000+0300-128586228.reframe

Copy the reframe file of the low resolution video:
$cp 2020-08-11-18-26-58-000+0300-5575817.reframe 2020-08-11-18-26-58-000+0300-128586228.reframe

Now if we launch GoPro Player for the gighe definition 360 video, the reframing made for the low resolution is used.
Note that albeit the reframing of the high definition video without HVEC hardware support is almost impossible, the rendering of the final output file doesn't use this hardware acceleration and is reasonable speedy.

The same method can be used to have several reframings for the same video file: Just copy the reframe file you want to use to the Application Support directory just before launching the GoPro Player:

$cp -f 2020-08-11-18-26-58-000+0300-128586228.reframe MyFirstVersion.reframe
$cp -f MyFirstVersion.reframe 2020-08-11-18-26-58-000+0300-128586228.reframe

The object of this project is to automate these prosedures and create an intuitive user interface for handling of these files.


