import React from "react";
import type { ComponentType } from "react";
import type { HostComponent, ViewProps } from "react-native";
import codegenNativeComponent from "react-native/Libraries/Utilities/codegenNativeComponent";
import codegenNativeCommands from "react-native/Libraries/Utilities/codegenNativeCommands";
import type {
  Float,
  WithDefault,
  BubblingEventHandler,
} from "react-native/Libraries/Types/CodegenTypes";

export type PlayerErrorEvent = Readonly<{
  error: string;
}>;

export type PlayerBufferEvent = Readonly<{
  bufferTime: Float;
  duration: Float;
}>;

export type PlayerProgressEvent = Readonly<{
  currentTime: Float;
  duration: Float;
  seeking: boolean;
}>;

export type PlayerStartEvent = Readonly<{
  uri: string;
}>;

export type PlayerLoadEvent = Readonly<{
  currentPosition: Float;
  duration: Float;
  naturalSize: {
    width: Float;
    height: Float;
    orientation: string;
  };
}>;

export type PlayerEndEvent = Readonly<{}>;

export type PlayerSeekEvent = Readonly<{
  currentTime: Float;
  seekTime: Float;
}>;

export interface NativeProps extends ViewProps {
  config: string;
  repeat: boolean;
  rate: Float;
  resizeMode: string;
  playerErrorSet?: WithDefault<boolean, false>;
  playerBufferSet?: WithDefault<boolean, false>;
  playerProgressSet?: WithDefault<boolean, false>;
  playerStartSet?: WithDefault<boolean, false>;
  playerLoadSet?: WithDefault<boolean, false>;
  playerEndSet?: WithDefault<boolean, false>;
  playerSeekSet?: WithDefault<boolean, false>;
  onPlayerError?: BubblingEventHandler<PlayerErrorEvent>;
  onPlayerBuffer?: BubblingEventHandler<PlayerBufferEvent>;
  onPlayerProgress?: BubblingEventHandler<PlayerProgressEvent>;
  onPlayerStart?: BubblingEventHandler<PlayerStartEvent>;
  onPlayerLoad?: BubblingEventHandler<PlayerLoadEvent>;
  onPlayerEnd?: BubblingEventHandler<PlayerEndEvent>;
  onPlayerSeek?: BubblingEventHandler<PlayerSeekEvent>;
}

interface NativeCommands {
  // @ts-ignore
  play: (viewRef: React.ElementRef<ComponentType>) => void;
  // @ts-ignore
  pause: (viewRef: React.ElementRef<ComponentType>) => void;
  // @ts-ignore
  stop: (viewRef: React.ElementRef<ComponentType>) => void;
  // @ts-ignore
  seek: (viewRef: React.ElementRef<ComponentType>, time: Float) => void;
  // @ts-ignore
  rerender: (viewRef: React.ElementRef<ComponentType>) => void;
}

export const Commands: NativeCommands = codegenNativeCommands<NativeCommands>({
  supportedCommands: ["play", "pause", "stop", "seek", "rerender"],
});

export default codegenNativeComponent<NativeProps>(
  "RNShakaPlayer",
  // eslint-disable-next-line prettier/prettier
) as HostComponent<NativeProps>;
