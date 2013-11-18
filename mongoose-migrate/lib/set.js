/*!
 * migrate - Set
 * Copyright (c) 2010 TJ Holowaychuk <tj@vision-media.ca>
 * MIT Licensed
 */
'use strict';

/**
 * Module dependencies.
 */

var EventEmitter = require('events').EventEmitter,
    fs = require('fs');

/**
 * Expose `Set`.
 */

module.exports = Set;

/**
 * Initialize a new migration `Set` with the given `path`
 * which is used to store data between migrations.
 *
 * @param {String} path
 * @api private
 */

function Set(path) {
    this.migrations = [];
    this.path = path;
    this.pos = 0;
}

/**
 * Inherit from `EventEmitter.prototype`.
 */

Set.prototype = EventEmitter.prototype;

/**
 * Save the migration data and call `fn(err)`.
 *
 * @param {Function} fn
 * @api public
 */

Set.prototype.save = function(fn){
    var self = this;

    // get the config file path from env variable
    var path = process.env.NODE_MONGOOSE_MIGRATIONS_CONFIG || 'migrations.json';
    var mongoose = require('mongoose');

    fs.readFile(path, 'utf8', function(err, json){
        var env = process.env.NODE_ENV || 'development';
        var config = JSON.parse(json)[env];

        if (err) {
            return fn(err);
        }

        mongoose.connect(config.db, function () {
            var Migration = mongoose.model(config.modelName);

            Migration.findOne().exec(function (err, doc) {
                if (!doc) {
                    var m = new Migration({ migration: self });
                    m.save(cb);
                } else {
                    doc.migration = self;
                    doc.save(cb);
                }
            });
        });

        function cb(err) {
            self.emit('save');
            if(fn) {
                fn(err);
            }
        }

    });
};

/**
 * Load the migration data and call `fn(err, obj)`.
 *
 * @param {Function} fn
 * @return {Type}
 * @api public
 */

Set.prototype.load = function(fn){
    this.emit('load');

    // get the config file path from env variable
    var path = process.env.NODE_MONGOOSE_MIGRATIONS_CONFIG || 'migrations.json';
    var mongoose = require('mongoose');

    fs.readFile(path, 'utf8', function(err, json){
        var env,
            config;
        if (err) {
            return fn(err);
        }

        env = process.env.NODE_ENV || 'development';
        config = JSON.parse(json)[env];

        mongoose.connect(config.db, function () {
            var Schema = mongoose.Schema;
            var MigrationSchema = new Schema(config.schema);
            var Migration = mongoose.model(config.modelName, MigrationSchema);

            Migration.findOne().exec(function (err, doc) {
                if (err) {
                    return fn(err);
                }
                try {
                    var obj = doc && doc.migration ?
                        doc.migration :
                        { pos: 0, migrations: [] };

                    fn(null, obj);
                } catch (err) {
                    fn(err);
                }
            });
        });
    });
};

/**
 * Run down migrations and call `fn(err)`.
 *
 * @param {Function} fn
 * @api public
 */

Set.prototype.down = function(fn, migrationName){
    this.migrate('down', fn, migrationName);
};

/**
 * Run up migrations and call `fn(err)`.
 *
 * @param {Function} fn
 * @api public
 */

Set.prototype.up = function(fn, migrationName){
    this.migrate('up', fn, migrationName);
};

/**
 * Migrate in the given `direction`, calling `fn(err)`.
 *
 * @param {String} direction
 * @param {Function} fn
 * @api public
 */

Set.prototype.migrate = function(direction, fn, migrationName){
    var self = this;
    fn = fn || function(){};
    this.load(function(err, obj){
        if (err) {
            if ('ENOENT' !== err.code) {
                return fn(err);
            }
        } else {
            self.pos = obj.pos;
            self.dbMigrations = obj.migrations;
        }
        self._migrate(direction, fn, migrationName);
    });
};

/**
 * Perform migration.
 *
 * @api private
 */

Set.prototype._migrate = function(direction, fn, migrationName){
    var self = this,
        migrations,
        migrationIndex,
        invokedMigrations;

    var dbMigrations = (this.dbMigrations || []).map(function(m) { return m.title; });

    migrations = this.migrations.filter(function(m) {
        var additionalMigrations = dbMigrations.indexOf(m.title) === -1;
        return direction === 'up' ? additionalMigrations : !additionalMigrations;
    });

    if (migrationName) {
        if (direction === 'up') {
            migrations = migrations.reverse();
        }

        migrationIndex = migrations.map(function(m) { return m.title; }).indexOf(migrationName);

        if (migrationIndex > -1) {
            migrations = migrations.slice(migrationIndex);
        } else {
            migrations = [];
        }

        migrations = migrations.reverse();
    } else {
        if (direction === 'down') {
            migrations = migrations.reverse();
        }
    }

    invokedMigrations = migrations.map(function(m) { return {title: m.title}; });

    function next(err, migration) {
        // error from previous migration
        if (err) {
            return fn(err);
        }

        // done
        if (!migration) {
            self.emit('complete');
            if(direction === 'up') {
                self.migrations = self.dbMigrations.concat(invokedMigrations).sort(function(m, n) { return m.title > n.title; });
            } else {
                invokedMigrations = invokedMigrations.map(function(m) { return m.title; });
                self.migrations = self.dbMigrations.filter(function(m) { return invokedMigrations.indexOf(m.title) === -1; });
            }
            delete self.dbMigrations;
            self.save(fn);
            return;
        }

        self.emit('migration', migration, direction);
        migration[direction](function(err){
            next(err, migrations.shift());
        });
    }

    next(null, migrations.shift());
};
