"use strict";
/*global require, module*/

import _          from "../../utils/lodash";
import throwErr   from "../../utils/throw";
import logger     from "../../utils/logger";
import Deployment from "./deployment";

let _initialized = false;
let _context = {};
let _callbacks = {};

function attachCallback(doc, callback){
  doc._hullCallbacks = doc._hullCallbacks || []
  if(!_.contains(doc._hullCallbacks,callback)){
    doc._hullCallbacks.push(callback);
  }
}

function embedDeployments(deployments, opts={}, callback, errback) {
  if (!deployments || !deployments.length){return;}
  if (opts.reset !== false) { Deployment.resetDeployments()}

  let embeds = [];
  let promises = [];

  logger.log('Embedding Deployments', deployments)
  for (let d = 0, l = deployments.length; d < l; d++) {
    let dpl = new Deployment(deployments[d], _context);
    promises.push(dpl.embed({ refresh: true }));
  }

  Promise.all(promises).then((deployments)=>{
    logger.log('Deployments resolved', deployments)
    if (_.isFunction(callback)){
      callback(_.pluck(deployments, 'value'))
    }
  },errback).catch(throwErr)
}

module.exports = {
  initialize: function(context) {
    _initialized = true;
    _context = context;
  },
  embed: function(deployments, opts, callback, errback) {
    embedDeployments(deployments, opts, callback, errback);
  },
  onEmbed: function() {
    let args = Array.prototype.slice.call(arguments);
    let callback;

    while (args.length>0 && !_.isFunction(callback)){
      callback = args.shift();
    }

    if (!_.isFunction(callback)) return false;

    let shipId = null;
    let cs = document._currentScript || document.currentScript;

    if(cs && cs.ownerDocument && cs.ownerDocument !== document){
      // we're inside an Import
      shipId = cs.ownerDocument.shipId;
      attachCallback(cs.ownerDocument, callback);
    } else {
      // We're executing a script.
      shipId = cs.getAttribute("data-hull-ship-script");
    }

    let deployments = Deployment.getDeployments(shipId);
    // In JS-mode, callbacks are passed down to the DeploymentStrategy,
    // In theother modes, they are ignored because we retreive the callbacks from the import document.
    if(deployments && deployments.length){
      for (var i = deployments.length - 1; i >= 0; i--) {
        if(deployments[i]){
          deployments[i].onEmbed(callback)
        }
      };
    }
  }
};
