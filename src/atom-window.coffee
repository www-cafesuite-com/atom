BrowserWindow = require 'browser_window'
ipc = require 'ipc'

module.exports =
class AtomWindow
  browserWindow: null

  constructor: ({bootstrapScript, resourcePath, @pathToOpen, exitWhenDone, @isSpec}) ->
    require('atom-application').addWindow(this)

    @browserWindow = new BrowserWindow show: false, title: 'Atom'
    @handleEvents()

    url = "file://#{resourcePath}/static/index.html?bootstrapScript=#{bootstrapScript}&resourcePath=#{resourcePath}"
    url += "&pathToOpen=#{@pathToOpen}" if @pathToOpen
    url += '&exitWhenDone=1' if exitWhenDone

    @browserWindow.loadUrl url

  handleEvents: ->
    @browserWindow.on 'destroyed', =>
      require('atom-application').removeWindow(this)

    if @isSpec
      # Spec window's web view should always have focus
      @browserWindow.on 'blur', =>
        @browserWindow.focusOnWebView()
    else
      @browserWindow.on 'close', (event) =>
        event.preventDefault()
        @sendCommand 'window:close'

  sendCommand: (command, args...) ->
    ipc.sendChannel @browserWindow.getProcessId(), @browserWindow.getRoutingId(), 'command', command, args...

  focus: -> @browserWindow.focus()

  isFocused: -> @browserWindow.isFocused()

  show: -> @browserWindow.show()
