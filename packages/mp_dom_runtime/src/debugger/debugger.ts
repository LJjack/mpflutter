import { Engine } from "../engine";
import { MPEnv, PlatformType } from "../env";

export function createDebugger(serverAddr: string, engine: Engine): Debugger {
  if (MPEnv.platformType === PlatformType.wxMiniProgram || MPEnv.platformType === PlatformType.swanMiniProgram) {
    if (!(__MP_TARGET_WEAPP__ || __MP_TARGET_SWANAPP__)) return null!;
    return new WXDebugger(serverAddr, engine);
  } else if (MPEnv.platformType === PlatformType.aliMiniProgram) {
    if (!__MP_TARGET_ALIAPP__) return null!;
    return new AliDebugger(serverAddr, engine);
  } else {
    if (!__MP_TARGET_BROWSER__) return null!;
    return new BrowserDebugger(serverAddr, engine);
  }
}

export interface Debugger {
  serverAddr: string;
  start(): void;
  sendMessage(message: string): void;
}

class WXDebugger implements Debugger {
  private messageQueue: string[] = [];
  private socket?: any;
  private connected = false;

  constructor(readonly serverAddr: string, readonly engine: Engine) {}

  start() {
    this.socket = MPEnv.platformScope.connectSocket({
      url: `ws://${this.serverAddr}/ws`,
    });
    this.socket.onOpen(() => {
      this.connected = true;
      this.socketDidConnect();
    });
    this.socket.onMessage((message: any) => {
      if (typeof message.data === "string") {
        this.socketDidReceiveMessage(message.data);
      }
    });
    this.socket!.onClose(() => {
      if (this.connected) {
        this.engine.componentFactory.cachedElement = {};
        this.engine.componentFactory.cachedView = {};
        MPEnv.platformScope.reLaunch({
          url: (() => {
            try {
              return (
                "/" +
                MPEnv.platformScope.getLaunchOptionsSync().path +
                "?" +
                this.encodePathParams(MPEnv.platformScope.getLaunchOptionsSync().query)
              );
            } catch (error) {
              return "/pages/index/index";
            }
          })(),
        });
      }
      this.connected = false;
      this.socketDidDisconnect();
    });
  }

  encodePathParams(params?: any): string {
    let searchParams: string[] = [];
    if (params) {
      for (const key in params) {
        searchParams.push(`${key}=${encodeURIComponent(params[key])}`);
      }
    }
    return searchParams.join("&");
  }

  socketDidConnect() {
    this.messageQueue.forEach((it) => {
      this.socket?.send({ data: it });
    });
    this.messageQueue = [];
  }

  socketDidDisconnect() {
    setTimeout(() => {
      this.start();
    }, 1000);
  }

  socketDidReceiveMessage(message: string) {
    this.engine.didReceivedMessage(message);
  }

  sendMessage(message: string) {
    if (!this.socket || !this.connected) {
      this.messageQueue.push(message);
      return;
    }
    this.socket.send({ data: message });
  }
}

class AliDebugger implements Debugger {
  private messageQueue: string[] = [];
  private connected = false;
  private listened = false;

  constructor(readonly serverAddr: string, readonly engine: Engine) {}

  start() {
    MPEnv.platformScope.connectSocket({
      url: `ws://${this.serverAddr}/ws`,
    });
    if (!this.listened) {
      this.listened = true;
      MPEnv.platformScope.onSocketOpen(() => {
        this.connected = true;
        this.socketDidConnect();
      });
      MPEnv.platformScope.onSocketMessage((message: any) => {
        if (typeof message.data === "string") {
          this.socketDidReceiveMessage(message.data);
        }
      });
      MPEnv.platformScope.onSocketClose(() => {
        if (this.connected) {
          this.engine.componentFactory.cachedElement = {};
          this.engine.componentFactory.cachedView = {};
          MPEnv.platformScope.reLaunch({
            url: (() => {
              try {
                return (
                  "/" +
                  MPEnv.platformScope.getLaunchOptionsSync().path +
                  "?" +
                  this.encodePathParams(MPEnv.platformScope.getLaunchOptionsSync().query)
                );
              } catch (error) {
                return "/pages/index/index";
              }
            })(),
          });
        }
        this.connected = false;
        this.socketDidDisconnect();
      });
    }
  }

  encodePathParams(params?: any): string {
    let searchParams: string[] = [];
    if (params) {
      for (const key in params) {
        searchParams.push(`${key}=${encodeURIComponent(params[key])}`);
      }
    }
    return searchParams.join("&");
  }

  socketDidConnect() {
    this.messageQueue.forEach((it) => {
      MPEnv.platformScope.sendSocketMessage({ data: it });
    });
    this.messageQueue = [];
  }

  socketDidDisconnect() {
    setTimeout(() => {
      this.start();
    }, 1000);
  }

  socketDidReceiveMessage(message: string) {
    this.engine.didReceivedMessage(message);
  }

  sendMessage(message: string) {
    if (!this.connected) {
      this.messageQueue.push(message);
      return;
    }
    MPEnv.platformScope.sendSocketMessage({ data: message });
  }
}

class BrowserDebugger implements Debugger {
  private messageQueue: string[] = [];
  private socket?: WebSocket;
  private connected = false;
  private needReload = false;

  constructor(readonly serverAddr: string, readonly engine: Engine) {}

  start() {
    let scheme = "ws";
    if (new URL(location.href).protocol === "https:") {
      scheme = "wss";
    }
    this.socket = new WebSocket(`${scheme}://${this.serverAddr}/ws`);
    this.socket.onopen = () => {
      if (this.needReload) {
        location.href = "?";
        return;
      }
      this.socketDidConnect();
      this.connected = true;
    };
    this.socket.onmessage = (message) => {
      if (typeof message.data === "string") {
        this.socketDidReceiveMessage(message.data);
      }
    };
    this.socket.onclose = () => {
      this.needReload = true;
      this.socketDidDisconnect();
    };
  }

  socketDidConnect() {
    this.messageQueue.forEach((it) => {
      this.socket?.send(it);
    });
    this.messageQueue = [];
  }

  socketDidDisconnect() {
    setTimeout(() => {
      this.start();
    }, 1000);
  }

  socketDidReceiveMessage(message: string) {
    this.engine.didReceivedMessage(message);
  }

  sendMessage(message: string) {
    if (!this.socket || this.socket.readyState != 1) {
      this.messageQueue.push(message);
      return;
    }
    this.socket.send(message);
  }
}
