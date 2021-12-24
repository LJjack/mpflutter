import { MPMethodChannel } from "..";
import { Engine } from "../engine";
import { PluginRegister } from "./plugin_register";

export class PlatformChannelIO {
  private pluginInstances: { [key: string]: any } = {};

  responseCallbacks: { [key: number]: [(result: any) => void, (error: any) => void] } = {};

  constructor(readonly engine: Engine) {
    for (const key in PluginRegister.registedChannels) {
      if (Object.prototype.hasOwnProperty.call(PluginRegister.registedChannels, key)) {
        const clazz = PluginRegister.registedChannels[key];
        try {
          this.pluginInstances[key] = new clazz();
          this.pluginInstances[key].channelName = key;
          this.pluginInstances[key].engine = engine;
        } catch (error) {
          console.error(error);
        }
      }
    }
  }

  async didReceivedPlatformChannel(message: any) {
    if (message.event === "invokeMethod") {
      const method = message.method;
      const beInvokeMethod = message.beInvokeMethod;
      const beInvokeParams = message.beInvokeParams;
      const seqId = message.seqId;
      const instance = this.pluginInstances[method];
      if (instance instanceof MPMethodChannel) {
        try {
          const result = await instance.onMethodCall(beInvokeMethod, beInvokeParams);
          this.engine.sendMessage(
            JSON.stringify({
              type: "platform_channel",
              message: {
                event: "callbackResult",
                result: JSON.stringify(result),
                seqId: seqId,
              },
            })
          );
        } catch (error) {
          this.engine.sendMessage(
            JSON.stringify({
              type: "platform_channel",
              message: {
                event: "callbackResult",
                result: "ERROR:" + error,
                seqId: seqId,
              },
            })
          );
        }
      }
    } else if (message.event === "callbackResult") {
      const seqId = message.seqId;
      const result = message.result;
      const callback = this.responseCallbacks[seqId];
      if (callback !== undefined && typeof result === "string") {
        if (result === "NOTIMPLEMENTED" || result.indexOf("ERROR:") === 0) {
          callback[1](result);
        } else {
          callback[0](JSON.parse(result));
        }
      }
      delete this.responseCallbacks[seqId];
    }
  }
}
