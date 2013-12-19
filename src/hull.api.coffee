define [
  'lib/utils/emitter'
  'lib/api/api'
  'lib/api/reporting',
  'lib/utils/entity'
  ], (emitter, api, reporting, entity) ->
    success = (api)->
      reporting = reporting.init(api)
      booted =
        on: emitter.on
        off: emitter.off
        emit: emitter.emit
        track: reporting.track
        flag: reporting.flag
        data:
          api: api.api
        login: api.auth.login
        logout: api.auth.logout
        util:
          entity: entity

      booted

    failure = (error)->
      console.error('Unable to start Hull.api', error)
      error

    init = (config)-> api.init(config)

    init: init
    success: success
    failure: failure
