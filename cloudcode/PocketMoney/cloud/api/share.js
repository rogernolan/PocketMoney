'use strict';

var Errors = require('../libs/errors');

shareAccount = function shareAccount(request, response) {
    console.log('ShareAccount')
}

acceptShare = function acceptShare(request, response) {
    console.log('acceptShare')

}

exports.shareList = shareAccount;
exports.acceptShare = acceptShare;