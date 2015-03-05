assign       = require 'object-assign'

_            = require '../utils/lodash'
promises     = require '../utils/promises'
clone        = require '../utils/clone'
EventBus     = require '../utils/eventbus'
Entity       = require '../utils/entity'
cloneConfig  = require '../utils/clone-config'

Api          = require './api'
Auth         = require './auth'
Flag         = require './flag/index'
Tracker      = require './track/index'
Traits       = require './traits/index'
Sharer       = require './sharer/index'

utils        = require '../utils/utils'

setupTracking = (track)->

  EventBus.on 'hull.*.share', (res)->
    track this.event, res

  EventBus.on 'hull.auth.create', (me)->
    providers = _.pluck me.identities, 'provider'
    track 'hull.auth.create', { providers: providers, main_identity: me.main_identity }

  EventBus.on 'hull.auth.login', (me, provider)->
    providers = _.pluck me.identities, 'provider'
    provider = provider || me.main_identity
    track 'hull.auth.login', { provider: provider, providers: providers, main_identity: me.main_identity }

  EventBus.on 'hull.auth.logout', ()-> track('hull.auth.logout')

class Client 

  constructor: (config={}, channel, currentUser)->

    @config = clone(config)
    @remoteConfig = clone(channel.remoteConfig)

    api   = new Api(config, channel, currentUser)
    auth  = new Auth(api)
    tracker = new Tracker(api)

    setupTracking(tracker.track)

    sharer = new Sharer(api, auth, currentUser)
    flag  = new Flag(api)
    traits= new Traits(api)

    if config.debug
      EventBus.on 'hull.**', (args...)->
        console.log("--HULL EVENT--[#{@event}]--", args...);

    # Creating the complete hull object we'll send back to the API
    @hull =
      config         : cloneConfig(config, @remoteConfig)
      utils          : utils
      api            : api.message
      currentUser    : currentUser.get
      entity         : Entity
      signup         : auth.signup
      logout         : auth.logout
      login          : auth.login
      linkIdentity   : auth.linkIdentity
      unlinkIdentity : auth.unlinkIdentity
      track          : tracker.track
      flag           : flag
      traits         : traits
      share          : sharer.share

    # Return an object that will be digested by Hull main file and
    # has everything

    @hull

module.exports = Client
