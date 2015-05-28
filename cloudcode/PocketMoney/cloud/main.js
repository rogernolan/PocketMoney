'use strict';

var accountAPI = require('./api/share')
// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("share-account", accountAPI.shareAccount);
Parse.Cloud.define("accept-share", accountAPI.acceptShare);
