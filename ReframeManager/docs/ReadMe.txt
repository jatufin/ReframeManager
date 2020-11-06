Reframe Manager - Application for managing reframe files and proxy editing of GoPro MAX 360 degree video files

0. Introduction

GoPro MAX is a action camera capable of shooting full 360 degree video. The footage can be afterwards reframed to normal high definition video using GoPro Player application on mobile device, windows PC or Mac. The original video is provided in high and low definition fomats which can be handled separatalely in the app. To produce high definition output, the reframing has to be made with the original high definition 360 degree video file, and the application itself doesn't give ability to use the low definition file as proxy. That is: You can't simply reframe the low quality file to produce high quality output.

The high quality 360 degree video file uses HVEC encoding, which at this writing in 2020 support for is missing from even relatively new Macbook Air models of 2017.

New mobile and devices and PC graphics adapters, as well as graphics adapters of the newer Macs have the support of HVEC encoding, so if the users of those systems can simply launch the GoPro Player on highe definition 360 degree video file, do the reframing and render high quality output. The software however doesn't give the ability to make different reframings for the same video: The reframing video is hidden from casual user, and normally the same reframing file is used whenever you open 360 degree video for reframing.

There is workaround for this: The reframing files in the application bundle folder can are interchangable, so one can do reframing for the low resolution 360 degree file and rename the reframe file produced by the softaware as it had been created for the corresponding high definition file. Now when the software is opened for reframing the hig definition footage, the reframing for made for the low resolution opens with it, and high definition output can be rendered.

Example:

After extracting a 360 degree video from the camera, we have three files:
NOTE: The date is creation date, not modification or access time. (command: $ls -lUT)

     size date            name
--------- --------------- ---------
128586228 11 Elo 18:26:58 GS010069.360 <- 360 degree HVEC encoded high definition video
  5575817 11 Elo 18:26:58 GS010069.LRV <- 360 degree low resolution video
    92163 11 Elo 18:26:58 GS010069.THM <- Still image preview

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

NOTE! The timestap in the reframe file name is created from the creation time of the video file saved in the file system, not from some magic numbers inside the video file itself.

The object of this project is to automate these prosedures and create an intuitive user interface for handling of these files.


1. Design

- Target platform: MacOS 10.15 (Catalina) or newer
- Programming language: Swift
- GUI framework: SwiftUI
- Also command line tools should be available
- Sandboxed: The application should be run from application bundle sandbox, so it cane be distributed safely
- Minimum configuration: Theres should be minimum amount of configuration settings or files
- Target: Directories. The application opens and manages directories, not signle video files or file groups

1.1. Default directories and their acronyms from this on:

Working directory: CWD
Default: ~/Documents

Player bundle: Playerdir
Default: ~/Library/Containers/com.gopro.GoPro-Player/Data/Library/Application Support$

If application is run sandboxed, these directories must be opened by user with a file dialog. The access rights will be valid until the application is shut down.

1.2. Data structure:

The application reads all the file names and properties and creates internal data structure based from their names, sizes and time stamps.
Only files with THM, 360, LRV or reframe extensions are recognized, all others all dismissed.
All information the application needs is saved in file names and properties.

A record for a video should be as follows:

struct Video360 {
    var name: String
    
    var previewImage: PreviewImage?     // .THM file extension
    var highDef360File: Video360File?   // .360 file extension
    var lowDef360File: Video360File?    // .LRV file extension
    
    var reframeFiles: [ReframeFile]     // .reframe file extension
}

struct PreviewImage {
    var fileName: String
}

struct Video360File {
    var fileName: String
    var size: Int
    var creationTime: Date()
    var reframeFileName: String { createReframeFileName() }
}

struct reframeFiles {
    var videoName: String       // This is the name found in the Video360 record
    var reframeName: String     // This is the name give by user to this particular reframing
    var fileName: String { "\(videoName).\(reframeName).reframe" }
        // The reframe name is store between first and last dots in the actual file name
        // Example: The original 360 video file is GS010069.360 and user has named the reframe as "My Reframe":
        // "GS010069.My Reframe.reframe"
}

When reading the directory, any THM, 360 or LRV file ancountered either creates a new record based on its name, or it is incrporated to the existing record if it is found by name. The records are stored in a dictionary, where the video name acts as key:

video360Files: [String:Video360File]

Main structure for a directory is:

struct Directory {
    var directoryURL: URL
    var video360Files: [String:Video360Files]
}



