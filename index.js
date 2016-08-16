'use strict'

var React = require('react-native');
var NativeModules = React.NativeModules;
var GzipUtilIOS = NativeModules.GzipUtil;

exports.gZipString = function gZipString (string, callback) {
  return GzipUtilIOS.gZipString(string, callback);
}