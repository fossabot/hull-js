_setup = null
_extend = null
currentFlavour = null


createLock = (locks, openDoorFn)->
  _locks = [].concat locks
  (lock)->
    index = _locks.indexOf lock
    openDoorFn() if !!~index and _locks.splice(index, 1).length and !_locks.length


# Helpers to manage the calls to functions defined from the start
# event if they are not available
_pool = _pool || {}
createPool = (name)->
  _pool[name] ?= []
  (args...)-> _pool[name].push args
deletePool = (name)->
  delete _pool[name]


# * Checks that it has not been called before
# * Augments coniguration
# * Unlocks the achievement :p
preInit = (config, cb, errb)->
  throw 'Hull.init has already been called' if _setup

  # Prepare config
  config.namespace = 'hull'
  config.debug = config.debug && { enable: true }

  _setup =
    config: config
    userSuccessFn: cb or ->
    userFailureFn: errb or ->

  bootstrapUnlock 'init'


_hull = window.Hull =
  on:         createPool 'events'
  track:      createPool 'tracks'
  init:       preInit

_hull.component =  createPool 'component' if HULL_ENV=="client"

# Wraps the success callback
# * Extends the global object
# * Reinjects events in the live app from the pool
# * Replays the track events
successCb = (args...)->
  extension = currentFlavour.success(args...)
  _hull = window.Hull = _extend(_hull, extension)
  # Prune callback queue
  _hull.events.on(data...) for data in _pool['events']
  deletePool('events')

  # Prune init queue
  _setup.userSuccessFn(_hull)

  booted.track(data...) for data in _pool['tracks']
  deletePool('tracks')

  booted.component(data...) for data in _pool['component'] if _pool['components'] if HULL_ENV=="client"
  deletePool('component')

  _hull


# Wraps the failure callback
# * Executes the failure behaviour defined by the current flavour
failureCb = (args...)->
  currentFlavour.failure(args...)
  _setup.userFailureFn(args...)

bootstrapUnlock = createLock ['init', 'require'], ->
  currentFlavour.condition(_setup.config).then(successCb, failureCb)

require ['flavour', 'underscore', 'lib/utils/version'], (flavour, _, version)->
  _hull.version = version
  _extend = _.extend
  currentFlavour = flavour
  bootstrapUnlock 'require'

