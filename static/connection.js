(function(main){
  function EventSourcePorts(elmPorts) {

    this.attachListeners = function(source) {
      source.addEventListener("handshake", function(event) {
        console.log("[HANDSHAKE]", event)
        elmPorts.handshakeEvents.send(JSON.parse(event.data))
      })

      source.addEventListener("event", function(event) {
        console.log("[MESSAGE]", event)
        var data = JSON.parse(event.data)
        // TODO: use primary event type with just one port instead!!
        elmPorts.actionEvents.send([data.action, data.body])
      })
    }
  }

  Connect.prototype.connect = function(url) {
    var e = new EventSource(url)
    this.attachListeners(e)
  }
  main.Connect = Connect
})(window)
