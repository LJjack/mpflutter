let eventMap = {
  tap: "click",
  confirm: "submit",
};

Component({
  properties: {
    dom: { type: Object },
    root: { type: String },
    style: { type: String },
  },
  data: {
    name: "renderer",
  },
  methods: {
    onEvent: (event) => {
      console.log("onEvent", event);
      getApp().miniDomEventHandlers[`${event.currentTarget.id.replace("d_", "")}`]?.emit(
        eventMap[event.type] ?? event.type,
        event
      );
    },
  },
});
