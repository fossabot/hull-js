GenericService    = require './generic_service'
superagent        = require 'superagent'

class GithubService extends GenericService
  name : 'github'
  path : 'github'

  constructor: (config, gateway)-> super(config,gateway)

  request : (request,callback,errback)=>
    token = @getSettings().credentials?.token

    {method, path, params} = request
    method = method.toUpperCase()
    path   = path.substring(1) if (path[0] == "/")

    url = "https://api.github.com/#{path}"

    s = superagent(method, url).send(params)
    s.set('Authorization', "token #{token}") if token
    s.end (response)->
      return errback(response.error.message) if response.error
      callback
        provider: @name
        response: response.body

module.exports = GithubService
