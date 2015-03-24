GenericShare = require './generic_share'

class TwitterShare extends GenericShare
  defaultMethod: 'tweet'

  constructor : (api, auth, currentUser, opts)->
    super(api, currentUser, 'twitter')

    @opts   = opts
    @params = opts.params || {}
    @opts.method   ||= @defaultMethod

    # Parameter name already is url. No need to touch

    return @sharePopup()

  sharePopup : ()->
    @opts.params.text ||= document.title

    [@opts.width, @opts.height] = [550, 420]
    @_popup("https://twitter.com/intent/#{@opts.method}", @opts, @params)

module.exports = TwitterShare
