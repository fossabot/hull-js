module.exports = {
  cookies       : require("cookies-js"),
  eventemitter2 : require("eventemitter2"),
  assign        : require("../polyfills/assign"),
  _             : require("./lodash"),
  isMobile      : require("./is-mobile"),
  uuid          : require("./uuid"),
  domready      : require("./domready"),
  Promise       : require("./promises"),
  superagent    : require("superagent")
};
