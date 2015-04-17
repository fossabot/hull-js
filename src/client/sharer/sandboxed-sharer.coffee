assign   = require '../../polyfills/assign'
_        = require '../../utils/lodash'
promises = require '../../utils/promises'

class SandboxedSharer

  constructor: (opts)->
    @shareMethod = opts.share
    @ship        = opts.ship
    @domRoot     = opts.domRoot

  setContainer: (iframe)->
    @domRoot = iframe if iframe?

  share: (opts={}, event={})=>

    event = assign({}, event, {hull_ship_id: @ship.id})

    # We place a fallback for the sharing target event
    # and pass in the iframe.
    # This way the Hull.share method will walk from the iframe container up.
    event = assign(event, {target: @domRoot}) if @domRoot?

    # Enrich UTM Tags Defaults
    opts.tags = assign({}, opts.tags, {utm_campaign:@ship.name})

    @shareMethod(opts,event)

module.exports = SandboxedSharer
