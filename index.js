'use strict'

var NativeGZip = require('react-native').NativeModules.GzipUtil

exports.gzipString = function gZipString (string) {
  return NativeGZip.gZipString(string)
}