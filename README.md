# react-native-shaka-player-ios

A React Native component for playing **MPEG-DASH** streams on **iOS**, backed by [`shaka-player-embedded`](https://github.com/shaka-project/shaka-player-embedded) (currently only **ClearKey-encrypted** content is supported).

The component's props, events, and imperative methods follow the [`react-native-video`](https://github.com/TheWidlarzGroup/react-native-video) API so it can be used as a near drop-in replacement when you need DASH/ClearKey playback on iOS. The surface is intentionally smaller — only what is needed to load, play, seek, and observe a DASH stream is exposed.

> **Platform:** iOS only. On Android the component renders `null`.

## Installation

```sh
yarn add react-native-shaka-player-ios
# or
npm install react-native-shaka-player-ios
```

Then install the iOS pods:

```sh
cd ios && pod install
```

The podspec vendors `ShakaPlayerEmbedded.xcframework` and `ShakaPlayerEmbedded.FFmpeg.xcframework` and requires iOS 13.0 or later.

## Usage

```tsx
import ShakaPlayer from "react-native-shaka-player-ios";

<ShakaPlayer
  source={{
    uri: "https://example.com/stream/manifest.mpd",
    drm: {
      type: "clearkey",
      localClearKeys: ["<keyId>:<key>"],
    },
  }}
  style={{ width: 320, height: 180 }}
  resizeMode="contain"
  paused={false}
  onLoad={(e) => console.log("loaded", e.duration)}
  onProgress={(e) => console.log(e.currentTime)}
  onError={(e) => console.warn(e.error)}
/>;
```

## Props

| Prop                     | Type                                                       | Default     | Description                                                          |
| ------------------------ | ---------------------------------------------------------- | ----------- | -------------------------------------------------------------------- |
| `source`                 | `{ uri: string; drm?: DrmConfig }`                         | _required_  | Manifest URI and optional DRM configuration.                         |
| `paused`                 | `boolean`                                                  | `false`     | Pauses playback when `true`.                                         |
| `repeat`                 | `boolean`                                                  | `false`     | Restarts playback from the beginning on `onEnd`.                     |
| `resizeMode`             | `"none" \| "contain" \| "cover" \| "stretch"`              | `"contain"` | How the video is scaled inside the view.                             |
| `rate`                   | `number`                                                   | `1`         | Playback rate (e.g. `0.5`, `1`, `2`).                                |
| `progressUpdateInterval` | `number` (ms)                                              | _native_    | How often `onProgress` fires, in milliseconds.                       |
| `style`                  | `ViewStyle`                                                | —           | Standard React Native view style. `width` and `height` are required. |

### `source.drm`

```ts
{
  type: "clearkey";
  localClearKeys?: string[]; // each entry is "keyId:key" (hex)
  licenseServer?: string;    // URL to a ClearKey license server
}
```

Provide either `localClearKeys` for static keys baked into the app, or `licenseServer` to fetch keys at runtime. Only `clearkey` is currently supported.

## Events

All event callbacks receive a single object argument and mirror the corresponding callbacks in `react-native-video`.

| Callback      | Payload                                                                            | When                                |
| ------------- | ---------------------------------------------------------------------------------- | ----------------------------------- |
| `onLoadStart` | `{ isNetwork, type, uri }`                                                         | The player has started loading.     |
| `onLoad`      | `{ currentTime, duration, naturalSize: { width, height, orientation } }`           | The manifest and media are ready.   |
| `onProgress`  | `{ currentTime, playableDuration, seekableDuration }`                              | Playback position changes.          |
| `onBuffer`    | `{ bufferTime, duration }`                                                         | Buffering state changes.            |
| `onSeek`      | `{ currentTime, seekTime, finished }`                                              | A seek operation completes.         |
| `onEnd`       | —                                                                                  | Playback reaches the end.           |
| `onError`     | `{ error: string }`                                                                | The native player reports an error. |

## Imperative methods

Grab a ref to the component and call any of the following:

```tsx
const playerRef = useRef<ShakaPlayer>(null);

<ShakaPlayer ref={playerRef} ... />

playerRef.current?.play();
playerRef.current?.seek(30);
```

| Method            | Description                                                          |
| ----------------- | -------------------------------------------------------------------- |
| `play()`          | Resume playback.                                                     |
| `pause()`         | Pause playback.                                                      |
| `stop()`          | Stop playback and tear down the active media.                        |
| `seek(time)`      | Seek to `time` seconds.                                              |
| `rerender()`      | Force the native view to re-layout (used internally on size change). |

## Compatibility with `react-native-video`

Props (`source`, `paused`, `repeat`, `resizeMode`, `rate`, `progressUpdateInterval`, `style`), event names and payloads (`onLoad`, `onProgress`, `onSeek`, `onBuffer`, `onEnd`, `onError`, `onLoadStart`), and the imperative methods (`play`, `pause`, `seek`) match `react-native-video`. Code that consumes `react-native-video` can in most cases switch to `ShakaPlayer` for DASH/ClearKey streams on iOS with only an import change.

The surface is deliberately a strict subset — features such as audio-track selection, text tracks, picture-in-picture, fullscreen control, poster, volume, mute, and Widevine/FairPlay DRM are **not** implemented.

---

## Playing local videos

`shaka-player-embedded` only loads media over HTTP(S); it does not accept `file://` URIs. To play files stored on the device you need to expose them over a local HTTP server and point the player at `http://localhost`.

The recommended approach is to embed [GCDWebServer](https://github.com/swisspol/GCDWebServer) inside the host application and serve the app's `Documents` directory.

### 1. Add the dependency to your `Podfile`

```ruby
pod "GCDWebServer", "~> 3.0"
```

Then run `pod install`.

### 2. Start the server when the app launches

#### Swift — `AppDelegate.swift`

```swift
import GCDWebServer

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
  private var webServer: GCDWebServer?

  func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    // ...

    let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let documentsDirectory = paths[0]

    webServer = GCDWebServer()
    webServer?.addGETHandler(
      forBasePath: "/",
      directoryPath: documentsDirectory,
      indexFilename: nil,
      cacheAge: 3600,
      allowRangeRequests: true
    )

    do {
      try webServer?.start(options: [
        "Port": 8080,
        "BindToLocalhost": true,
      ])
      NSLog("Web-server started")
    } catch {
      NSLog("Error starting web-server %@", error.localizedDescription)
    }

    // ...
    return true
  }
}
```

#### Objective-C — `AppDelegate.mm`

```objc
#import "GCDWebServer.h"
#import "GCDWebServerDataResponse.h"

@implementation AppDelegate
GCDWebServer* _webServer;

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // ...

  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];

  _webServer = [[GCDWebServer alloc] init];
  [_webServer addGETHandlerForBasePath:@"/"
                         directoryPath:documentsDirectory
                         indexFilename:nil
                              cacheAge:3600
                    allowRangeRequests:YES];

  NSError *error;
  [_webServer startWithOptions:@{ @"Port": @8080, @"BindToLocalhost": @YES }
                         error:&error];
  if (error != nil) {
    NSLog(@"Error starting web-server %@", error);
  } else {
    NSLog(@"Web-server started");
  }

  // ...
  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

@end
```

Place your DASH manifest and segments inside the app's `Documents` directory (for example by downloading them at runtime, or copying from the bundle on first launch).

### 3. Point the player at `http://localhost`

```tsx
<ShakaPlayer
  ref={setRef}
  source={{
    uri: "http://localhost:8080/video.mpd",
    drm: {
      type: "clearkey",
      localClearKeys: [`${keyId}:${key}`],
    },
  }}
  onLoad={onLoad}
  onError={onError}
  onProgress={onProgress}
  resizeMode={resizeMode}
  rate={playbackRate}
  progressUpdateInterval={100}
  paused={paused}
  style={{ width: 300, height: 300 }}
/>
```

## License

MIT