'use strict';
var Handlebars = require('handlebars');
var Helpers = require('./helpers')(Handlebars);
var util = require('util');
var extend = require('extend');
var path = require('path');
var yeoman = require('yeoman-generator');
var yosay = require('yosay');
var sh = require('execSync');

var RailsGenerator = yeoman.generators.Base.extend({
  initializing: function () {
    this.pkg = require('../package.json');
    this.parseFile = function(body) {
      var options = {
        rubyVersion: Helpers.recentRubyVersion(),
        projectSlug: this.props.project.toLowerCase().replace(/[^a-z]+/g, '')
      };
      extend(options, this.props);
      return Handlebars.compile(body)(options);
    };
  },

  prompting: function () {
    var done = this.async();

    // Have Yeoman greet the user.
    this.log(yosay(
      'Welcome to the fabulous Rails generator!'
    ));

    var prompts = [
    {
      type: 'input',
      name: 'project',
      message: 'What is the project name?',
      validate: function(value) {
        return value.length > 0;
      }
    }, {
      type: 'checkbox',
      name: 'rdbms',
      message: 'Which databases do you plan to use?',
      choices: [
        {name: 'SQLite', value: 'sqlite3'},
        {name: 'MySQL', value: 'mysql2'},
        {name: 'PostgreSQL', value: 'pg'}
      ]
    }, {
      type: 'list',
      name: 'template',
      message: 'Which templating system do you want to use?',
      choices: [
        {name: 'ERB', value: 'erb'},
        {name: 'HAML', value: 'haml-rails'},
        {name: 'Slim', value: 'slim'}
      ],
      default: 'haml-rails'
    }, {
      type: 'list',
      name: 'test',
      message: 'Which testing system do you want to use?',
      choices: [
        {name: 'RSpec', value: 'rspec'},
        {name: 'Test::Unit', value: 'test'}
      ],
      default: 'rspec'
    }, {
      type: 'list',
      name: 'integration',
      message: 'Which integration tests driver do you want to use?',
      choices: [
        {name: 'None (capybara disabled)', value: 'none'},
        {name: 'Rack Test', value: 'rack-test'},
        {name: 'Selenium', value: 'selenium'},
        {name: 'Capybara-webkit', value: 'webkit'},
        {name: 'Poltergeist', value: 'poltergeist'}
      ],
      default: 'selenium'
    }, {
      type: 'confirm',
      name: 'coverage',
      message: 'Do you want to use code coverage?',
      default: true
    }, {
      type: 'checkbox',
      name: 'extra',
      message: 'Which of this extra tools do you plan to use?',
      choices: [
        {name: 'Devise', value: 'devise'},
        {name: 'ActiveAdmin', value: 'activeadmin'},
        {name: 'CanCanCan', value: 'cancancan'},
        {name: 'Paperclip', value: 'paperclip'},
        {name: 'Geocoder', value: 'geocoder'},
        {name: 'Kaminari', value: 'kaminari'}
      ]
    }, {
      type: 'confirm',
      name: 'pow',
      message: 'Do you want to use POW for development?',
      default: true
    }, {
      type: 'confirm',
      name: 'heroku',
      message: 'Do you want to deploy to heroku?',
      default: false
    }];

    this.prompt(prompts, function (props) {
      this.props = props;

      done();
    }.bind(this));
  },

  writing: {
    app: function () {
      this.dest.mkdir('bin');
      this.dest.mkdir('.git-hooks');
      this.dest.mkdir('.git-hooks/pre_commit');
      this.copy('_Gemfile', 'Gemfile', this.parseFile.bind(this));
      this.copy('_package.json', 'package.json', this.parseFile.bind(this));
      this.src.copy('git-hooks/_pre_commit/_rspec.rb', '.git-hooks/pre_commit/rspec.rb');
    },

    projectfiles: function () {
      this.src.copy('envrc', '.envrc');
      this.src.copy('editorconfig', '.editorconfig');
      this.src.copy('gitignore', '.gitignore');
      this.src.copy('jshintrc', '.jshintrc');
      this.src.copy('overcommit.yml', '.overcommit.yml');
      this.src.copy('rspec', '.rspec');
      this.src.copy('rubocop.yml', '.rubocop.yml');
      this.copy('ruby-version', '.ruby-version', this.parseFile.bind(this));
      this.copy('ruby-gemset', '.ruby-gemset', this.parseFile.bind(this));
      if (this.props.pow) {
        this.src.copy('powrc', '.powrc');
      }
    }
  },

  end: function () {
    this.installDependencies();
    sh.exec('ln -s node_modules/jscs/bin/jscs bin/jscs');
    sh.exec('ln -s node_modules/jshint/bin/jshint bin/jshint');
    sh.exec('direnv allow .');
  }
});

module.exports = RailsGenerator;
