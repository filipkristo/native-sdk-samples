![Deezer](http://cdn-files.deezer.com/img/press/new_logo_white.jpg "Deezer") 

# Deezer Native SDK Samples
Sample applications using Deezer Native SDK.

This repo contains the samples that demonstrate the integration of the Deezer Native Software Development Kit (SDK).

# Available Samples

## NanoPlayer

This sample illustrates a simple use of the Deezer Native SDK :

 - The user can authenticate himself using his access token.
 - He can play a track.

### Features

 - Authenticating a user using his access token.
 - Playing a song from its id.

### Build instructions

* Get the latest version of the Deezer Native SDK
To build this sample, you need to download the latest version of [Deezer Native SDK][1] and unzip it in `<native-sdk-samples>` folder following this file tree:
```
<native-sdk-samples>
├── libdeezer
│   └── SDK
│      ├── Bins
│      └── Include
├── NanoPlayer
└── README.md
```


* Build the sample

(On Linux)

```
> cd NanoPlayer
> make
```


### Run this sample

(On Linux)

```
> ./NanoPlayer
```

 [1]: http://developers.deezer.com/sdk/native
