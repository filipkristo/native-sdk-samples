![Deezer](http://cdn-files.deezer.com/img/press/new_logo_white.jpg "Deezer") 

# Deezer Native SDK Samples
Sample applications using the Deezer Native SDK.

This repository contains a set of samples that demonstrate the integration of the Deezer Native Software Development Kit (SDK).

# Available Samples

## NanoPlayer

NanoPlayer is a C application which uses Deezer's Native SDK to play a song once a user was authenticated.

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
├── NanoPlayer
└── README.md
```

* To build the sample on Linux and Mac OS
```
> cd NanoPlayer
> make
```

* To build the sample on Windows
--> TBD
```
> cd NanoPlayer
> make
```


### Run this sample

On Linux the application will need pulseaudio packaged installed.

```
> ./NanoPlayer
```

 [1]: http://developers.deezer.com/sdk/native
