import React, { Component } from "react";
import { Platform, ViewStyle } from "react-native";
// @ts-ignore
// eslint-disable-next-line import/extensions
import resolveAssetSource from "react-native/Libraries/Image/resolveAssetSource.js";
import type {
  Float,
  WithDefault,
  BubblingEventHandler,
} from "react-native/Libraries/Types/CodegenTypes";
import ShakaPlayerView, {
  PlayerBufferEvent,
  PlayerEndEvent,
  PlayerErrorEvent,
  PlayerLoadEvent,
  PlayerProgressEvent,
  PlayerSeekEvent,
  PlayerStartEvent,
  Commands as RNShakaPlayerManager,
} from "./ShakaPlayerViewNativeComponent";

let playerId = 0;

const RCT_RNSHAKAPLAYER_REF = "RNShakaPlayerKey";

export type ShakaPlayerProps = {
  source: {
    uri: string;
    drm?: {
      type: "clearkey";
      localClearKeys?: string[];
      licenseServer?: string;
    };
  };
  updateInterval?: number;
  paused?: boolean;
  repeat?: boolean;
  resizeMode?: "none" | "contain" | "cover" | "stretch";
  rate?: number;
  progressUpdateInterval?: number;
  style?: ViewStyle;
  onLoadStart?: (e: { isNetwork: boolean; type: string; uri: string }) => void;
  onLoad?: (e: {
    currentTime: number;
    duration: number;
    naturalSize: {
      width: number;
      height: number;
      orientation: string;
    };
  }) => void;
  onError?: (e: { error: string }) => void;
  onSeek?: (e: {
    currentTime: number;
    seekTime: number;
    finished: boolean;
  }) => void;
  onProgress?: (e: {
    currentTime: number;
    playableDuration: number;
    seekableDuration: number;
  }) => void;
  onBuffer?: (e: { bufferTime: number; duration: number }) => void;
  onEnd?: () => void;
};

export default class ShakaPlayer extends Component<ShakaPlayerProps> {
  playerId: number;

  paused: boolean;

  repeat: boolean;

  resizeMode:
    | "ScaleNone"
    | "ScaleToFill"
    | "ScaleAspectFit"
    | "ScaleAspectFill";

  rate: number;

  progressUpdateInterval: number | null;

  viewRef: React.RefObject<any>;

  constructor(props: ShakaPlayerProps) {
    super(props);

    this.playerId = playerId;
    playerId += 1;

    this.paused = !!props.paused;
    this.repeat = !!props.repeat;
    this.resizeMode = ShakaPlayer.getResizeMode(props.resizeMode || "contain");
    this.rate = props.rate || 1;
    this.progressUpdateInterval = props.progressUpdateInterval
      ? props.progressUpdateInterval / 1000
      : 0.1;

    this.viewRef = React.createRef();
  }

  shouldComponentUpdate(nextProps: ShakaPlayerProps) {
    const { source, paused, repeat, resizeMode, rate, style } = nextProps;
    const {
      source: prevSoruce,
      paused: prevPaused,
      repeat: prevRepeat,
      rate: prevRate,
      resizeMode: prevResizeMode,
      style: prevStyle,
    } = this.props;
    let sourceSame = true;
    if (source && !prevSoruce) {
      sourceSame = false;
    } else if (!source && prevSoruce) {
      sourceSame = true;
    } else if (source && prevSoruce && source.uri !== prevSoruce.uri) {
      sourceSame = false;
    }
    let drmSame = true;
    const drm = source?.drm;
    const prevDrm = prevSoruce?.drm;
    if (drm && !prevDrm) {
      drmSame = false;
    } else if (!drm && prevDrm) {
      drmSame = false;
    } else if (drm && prevDrm && drm.type !== prevDrm.type) {
      drmSame = false;
    } else if (drm && prevDrm && drm.licenseServer !== prevDrm.licenseServer) {
      drmSame = false;
    } else if (
      drm &&
      prevDrm &&
      !drm.localClearKeys &&
      prevDrm.localClearKeys
    ) {
      drmSame = false;
    } else if (
      drm &&
      prevDrm &&
      drm.localClearKeys &&
      !prevDrm.localClearKeys
    ) {
      drmSame = false;
    } else if (
      drm &&
      prevDrm &&
      drm.localClearKeys &&
      prevDrm.localClearKeys &&
      drm.localClearKeys?.length !== prevDrm.localClearKeys?.length
    ) {
      drmSame = false;
    } else if (drm && prevDrm && drm.localClearKeys && prevDrm.localClearKeys) {
      drmSame = !drm.localClearKeys.some(
        (clearKey, i) => !(prevDrm.localClearKeys?.[i] === clearKey),
      );
    }
    if (paused !== prevPaused) {
      if (paused) {
        this.pause();
      } else {
        this.play();
      }
    }
    if (
      !sourceSame ||
      !drmSame ||
      repeat !== prevRepeat ||
      resizeMode !== prevResizeMode ||
      rate !== prevRate ||
      style?.width !== prevStyle?.width ||
      style?.height !== prevStyle?.height
    ) {
      return true;
    }
    return false;
  }

  componentDidUpdate(prevProps: Readonly<ShakaPlayerProps>): void {
    const { style } = this.props;
    const { style: prevStyle } = prevProps;
    if (
      style?.width !== prevStyle?.width ||
      style?.height !== prevStyle?.height
    ) {
      this.rerender();
    }
  }

  static getResizeMode(
    resizeMode: "none" | "contain" | "cover" | "stretch",
  ): "ScaleNone" | "ScaleToFill" | "ScaleAspectFit" | "ScaleAspectFill" {
    let nativeResizeMode:
      | "ScaleNone"
      | "ScaleToFill"
      | "ScaleAspectFit"
      | "ScaleAspectFill" = "ScaleNone";
    if (resizeMode === "stretch") {
      nativeResizeMode = "ScaleToFill";
    } else if (resizeMode === "contain") {
      nativeResizeMode = "ScaleAspectFit";
    } else if (resizeMode === "cover") {
      nativeResizeMode = "ScaleAspectFill";
    }

    return nativeResizeMode;
  }

  play() {
    if (RNShakaPlayerManager) {
      RNShakaPlayerManager.play(this.viewRef.current as never);
    }
  }

  pause() {
    if (RNShakaPlayerManager) {
      RNShakaPlayerManager.pause(this.viewRef.current as never);
    }
  }

  stop() {
    if (RNShakaPlayerManager) {
      RNShakaPlayerManager.stop(this.viewRef.current as never);
    }
  }

  seek(time: number) {
    if (RNShakaPlayerManager) {
      RNShakaPlayerManager.seek(this.viewRef.current as never, time);
    }
  }

  rerender() {
    if (RNShakaPlayerManager) {
      RNShakaPlayerManager.rerender(this.viewRef.current as never);
    }
  }

  render() {
    if (Platform.OS === "android") {
      return null;
    }
    const {
      source,
      onError,
      onBuffer,
      onProgress,
      onLoadStart,
      onLoad,
      onEnd,
      onSeek,
      repeat,
      resizeMode,
      rate,
      style,
    } = this.props;
    const assetResoved = resolveAssetSource(source) || {};

    let { uri } = assetResoved;
    if (uri && uri.match(/^\//)) {
      uri = `file://${uri}`;
    }
    uri = uri || "/";

    const isNetwork = !!(uri && uri.match(/^https?:/));

    const refKey = `${RCT_RNSHAKAPLAYER_REF}-${this.playerId}`;

    let clearKeyLicenseServer = "";
    if (
      source.drm &&
      source.drm.type === "clearkey" &&
      source.drm.licenseServer
    ) {
      clearKeyLicenseServer = source.drm.licenseServer;
    }
    const localClearKeys: { key: string; value: string }[] = [];
    if (
      source.drm &&
      source.drm.type === "clearkey" &&
      source.drm.localClearKeys
    ) {
      source.drm.localClearKeys.forEach((localClearKey) => {
        const keys = localClearKey.split(":");
        if (keys[0] && keys[1]) {
          localClearKeys.push({ key: keys[0], value: keys[1] });
        }
      });
    }

    const nativeProps: {
      config: string;
      repeat: boolean;
      rate: Float;
      resizeMode: string;
      style?: ViewStyle;
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
    } = {
      config: JSON.stringify({
        uri,
        clearKeyLicenseServer,
        localClearKeys,
        paused: this.paused,
        repeat: this.repeat,
        rate: this.rate,
        resizeMode: this.resizeMode,
        progressInterval: this.progressUpdateInterval,
      }),
      repeat: !!repeat,
      rate: rate || 1,
      resizeMode: ShakaPlayer.getResizeMode(resizeMode || "contain"),
      style,
    };
    if (onBuffer) {
      nativeProps.onPlayerBuffer = (e: { nativeEvent: PlayerBufferEvent }) =>
        onBuffer(e.nativeEvent);
      nativeProps.playerBufferSet = true;
    }
    if (onError) {
      nativeProps.onPlayerError = (e: { nativeEvent: PlayerErrorEvent }) =>
        onError(e.nativeEvent);
      nativeProps.playerErrorSet = true;
    }
    if (onProgress) {
      nativeProps.onPlayerProgress = (e: {
        nativeEvent: PlayerProgressEvent;
      }) =>
        onProgress({
          currentTime: e.nativeEvent.currentTime,
          playableDuration: e.nativeEvent.duration,
          seekableDuration: e.nativeEvent.duration,
        });
      nativeProps.playerProgressSet = true;
    }
    if (onLoadStart) {
      nativeProps.onPlayerStart = (e: { nativeEvent: PlayerStartEvent }) =>
        onLoadStart({
          isNetwork,
          type: "",
          uri: e.nativeEvent.uri,
        });
      nativeProps.playerStartSet = true;
    }
    if (onLoad) {
      nativeProps.onPlayerLoad = (e: { nativeEvent: PlayerLoadEvent }) =>
        onLoad({
          currentTime: e.nativeEvent.currentPosition,
          duration: e.nativeEvent.duration,
          naturalSize: e.nativeEvent.naturalSize,
        });
      nativeProps.playerLoadSet = true;
    }
    if (onEnd) {
      nativeProps.onPlayerEnd = () => onEnd();
      nativeProps.playerEndSet = true;
    }
    if (onSeek) {
      nativeProps.onPlayerSeek = (e: { nativeEvent: PlayerSeekEvent }) =>
        onSeek({
          currentTime: e.nativeEvent.currentTime,
          seekTime: e.nativeEvent.seekTime,
          finished: false,
        });
      nativeProps.playerSeekSet = true;
    }

    return <ShakaPlayerView ref={this.viewRef} key={refKey} {...nativeProps} />;
  }
}
