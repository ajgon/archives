'use strict';
var spawn = require('child_process').spawn;
var sh = require('execSync');
var Q = require('q');

String.prototype.trim = function() { return this.replace(/^\s+|\s+$/g, ''); };

var Helpers = {
  os: {},
  recentRubyVersion: function() {
    var osType = sh.exec('uname -s').stdout.trim();
    switch(osType) {
      case 'Darwin':
        this.os.name = 'osx';
        this.os.version = sh.exec('sw_vers -productVersion').stdout.trim();;
        this.os.arch = sh.exec('uname -m').stdout.trim();
    };
    if (this.os.name) {
      return sh.exec('curl -L http://rvm.io/binaries/' + this.os.name + '/' + this.os.version + '/' + this.os.arch).stdout.match(/ruby-[0-9]\.[0-9]\.[0-9]/g).sort().reverse()[0].replace('ruby-', '');
    }
    return false;
  },
  userId: function() {
    return sh.exec('whoami').stdout.trim();
  },
  run: function(cmd, args) {
    var sp;
    var deferred = Q.defer();
    args = args === undefined ? [] : args;
    sp = spawn(cmd, args);
    sp.stdout.on('data', function (data) {
      process.stdout.write(data.toString());
    });
    sp.on('exit', function (code) {
      if (code === 0) {
        return deferred.resolve(code);
      }
      console.log('reject');
      return deferred.reject(new Error('Command failed'));
    });
    return deferred.promise;
  }
};

module.exports = function(Handlebars) {
  Handlebars.registerHelper('ifCond', function (v1, operator, v2, options) {
    switch (operator) {
        case '==':
            return (v1 == v2) ? options.fn(this) : options.inverse(this);
        case '===':
            return (v1 === v2) ? options.fn(this) : options.inverse(this);
        case '!=':
            return (v1 != v2) ? options.fn(this) : options.inverse(this);
        case '!==':
            return (v1 !== v2) ? options.fn(this) : options.inverse(this);
        case '<':
            return (v1 < v2) ? options.fn(this) : options.inverse(this);
        case '<=':
            return (v1 <= v2) ? options.fn(this) : options.inverse(this);
        case '>':
            return (v1 > v2) ? options.fn(this) : options.inverse(this);
        case '>=':
            return (v1 >= v2) ? options.fn(this) : options.inverse(this);
        case '&&':
            return (v1 && v2) ? options.fn(this) : options.inverse(this);
        case '||':
            return (v1 || v2) ? options.fn(this) : options.inverse(this);
        default:
            return options.inverse(this);
    }
  });
  return Helpers;
};
