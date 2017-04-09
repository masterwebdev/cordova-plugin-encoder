module.exports = {
    encode: function (path, start_position, end_position, successCallback, errorCallback) {
        cordova.exec(successCallback, errorCallback, "Encoder", "encode", [path, start_position, end_position]);
    }
};