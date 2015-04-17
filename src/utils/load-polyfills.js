"use strict";
/*global import, module*/
import _            from "./lodash";
import scriptLoader from "./script-loader";

// Hardcoded Polyfills
require("../polyfills/xhr-xdr");

var polyfills = {
  "WeakMap"                  : function(){ return typeof WeakMap !== "undefined";  },
  "Array.prototype.indexOf"  : function(){ return "indexOf" in Array.prototype;    },
  "Array.prototype.map"      : function(){ return "map"     in Array.prototype;    },
  "Array.prototype.reduce"   : function(){ return "reduce"  in Array.prototype;    },
  "Array.prototype.some"     : function(){ return "some"    in Array.prototype;    },
  "Function.prototype.bind"  : function(){ return "bind"    in Function.prototype; },
  "Object.keys"              : function(){ return "keys"    in Object;             },
  "HTMLImports"              : function(){ return "import" in document.createElement("link");},
  "Element.prototype.classList" : function(){ return "classList" in document.documentElement},
  "Object.defineProperty"    : function(){
    if (Object.defineProperty){ return true;}
    return false;
  },
  "Event"                    : function(){
    if (!("Event" in global)){ return false; }
    if (typeof global.Event === "function"){ return true; }

    try{
      new Event("click");
      return true;
    } catch(e){
      return false;
    }
  }
};

var allGood = _.every(polyfills, function(tst){ return !!tst(); });

module.exports = function(config){
  if(allGood){
    dfd = promises.deferred()
    dfd.resolve();
    return dfd.promise;
  }

  var file = (config.debug)?"polyfill.min.js":"polyfill.js";
  var url = `//2ee5883f.ngrok.com/v1/${file}?features=${_.keys(polyfills).join(",")}`
  return scriptLoader({ src:url, document:config.document });

};
