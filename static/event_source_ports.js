(function(main){
  function EventSourcePorts(elmPorts) {

    this.attachListeners = function(source) {
      source.addEventListener("handshake", function(event) {
        var connections = JSON.parse(event.data)
        console.log("[HANDSHAKE]", connections)
        elmPorts.handshakeEvents.send(connections)
      })

      source.addEventListener("message", function(event) {
        var data = JSON.parse(event.data)
        console.log("[MESSAGE]:", data, event.type)
        // TODO: use primary event type with just one port instead!!
        elmPorts.connectionEvents.send([data.action, data.body])
      })
    }
  }

  EventSourcePorts.prototype.connect = function(url) {
    var e = new EventSource(url)
    this.attachListeners(e)
  }
  main.EventSourcePorts = EventSourcePorts
})(window)
