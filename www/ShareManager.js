var exec = require('cordova/exec');

exports.shareAction = function(arg0, success, error) {
    exec(success, error, "ShareManager", "shareAction", arg0);
};