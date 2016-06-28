![Deezer](http://cdn-files.deezer.com/img/press/new_logo_white.jpg "Deezer") 

## OfflineModePlayer

OfflineModePlayer is a MacOSX application which uses Deezer's Native SDK to enable offline mode playback of an album or a playlist once a user was authenticated.

### Features

 - User authentication
 - Playing a Deezer song.

### Build instructions

* Download the latest version of the [Deezer Native SDK][1]
* Unzip it and place the folder, renamed into NativeSDK, at the root of this repository, such as shown below:
```
<native-sdk-samples>
├── NativeSDK
│      ├── Bins
│      └── Include
├── OfflineModePlayer
└── README.md
```

* To build the sample on MacOSX

Open `OfflineModePlayer.xcodeproj` with Xcode (7.2.1 or upper).

### Run this sample


* On MacOSX

Run it through Xcode debug tool.

 [1]: http://developers.deezer.com/sdk/native
