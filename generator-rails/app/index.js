'use strict';
var Handlebars = require('handlebars');
var Helpers = require('./helpers')(Handlebars);
var path = require('path');
var yeoman = require('yeoman-generator');
var yosay = require('yosay');
var chalk = require('chalk');

var RailsGenerator = yeoman.generators.Base.extend({
  initializing: function () {
    this.pkg = require('../package.json');
    this.parseFile = function(body) {
      return Handlebars.compile(body)(this.props);
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
      default: process.cwd().split(path.sep).pop(),
      validate: function(value) {
        return value.length > 0;
      }
    }, {
      type: 'input',
      name: 'name',
      message: 'What is the project author name?',
      default: Helpers.gitUsername(),
      validate: function(value) {
        return value.length > 0;
      }
    }, {
      type: 'input',
      name: 'email',
      message: 'What is the project author email?',
      default: Helpers.gitEmail(),
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
        {name: 'HAML', value: 'haml'},
        {name: 'Slim', value: 'slim'}
      ],
      default: 'haml'
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
      props.rdbms = props.rdbms.length === 0 ? ['sqlite3'] : props.rdbms;
      if (props.extra.indexOf('devise') !== -1 && props.rdbms.indexOf('sqlite3') === -1) {
        this.props.rdbms.push('sqlite3');
      }
      this.props.dbUsername = props.rdbms === 'mysql2' ? 'root' : Helpers.userId();
      this.props.dbAdapter = [props.rdbms.reverse()[0].replace('pg', 'postgresql')];
      this.props.email = props.email.replace(/@/, ' [at] ');
      this.props.rubyVersion = Helpers.recentRubyVersion();
      this.props.projectSlug = this.props.project.toLowerCase().replace(/[^a-z]+/g, '');
      done();
    }.bind(this));
  },

  writing: {
    app: function () {
      this.dest.mkdir('.git-hooks');
      this.dest.mkdir('.git-hooks/pre_commit');
      this.dest.mkdir('bin');
      this.dest.mkdir('app');
      this.dest.mkdir('app/views');
      this.dest.mkdir('app/views/layouts');
      this.dest.mkdir('config');
      this.dest.mkdir('public');

      this.copy('_Gemfile', 'Gemfile', this.parseFile.bind(this));
      this.copy('ruby-version', '.ruby-version', this.parseFile.bind(this));
      this.copy('ruby-gemset', '.ruby-gemset', this.parseFile.bind(this));
      switch(this.props.template) {
        case 'erb':
          this.copy('_app/_views/_layouts/_application.html.erb', 'app/views/layouts/application.html.erb', this.parseFile.bind(this));
        break;
        case 'slim':
          this.copy('_app/_views/_layouts/_application.html.slim', 'app/views/layouts/application.html.slim', this.parseFile.bind(this));
        break;
        case 'haml':
          this.copy('_app/_views/_layouts/_application.html.haml', 'app/views/layouts/application.html.haml', this.parseFile.bind(this));
        break;
      }
      this.copy('_config/_database.yml.sample', 'config/database.yml.sample', this.parseFile.bind(this));
      this.copy('_public/_humans.txt', 'public/humans.txt', this.parseFile.bind(this));
    },

    projectfiles: function () {
      this.src.copy('editorconfig', '.editorconfig');
      this.src.copy('gitignore', '.gitignore');
      this.src.copy('jshintrc', '.jshintrc');
      this.src.copy('overcommit.yml', '.overcommit.yml');
      if (this.props.pow) {
        this.src.copy('powrc', '.powrc');
      }
      this.src.copy('rspec', '.rspec');
      this.src.copy('rubocop.yml', '.rubocop.yml');
      this.src.copy('git-hooks/_pre_commit/_rspec.rb', '.git-hooks/pre_commit/rspec.rb');
      this.src.copy('_public/_browserconfig.xml', 'public/browserconfig.xml');
      this.src.copy('_public/_robots.txt', 'public/robots.txt');
    }
  },

  end: function () {
    var self = this;
    var rvmVersion = 'ruby-' + self.props.rubyVersion + '@' + self.props.projectSlug;
    Helpers.run('true').then(function () {
      process.stdout.write(chalk.blue('Creating rvm environment' + '\n'));
      return Helpers.run('rvm', ['ruby-' + self.props.rubyVersion, 'do', 'rvm', 'gemset', 'create', self.props.projectSlug]);
    }).then(function () {
      process.stdout.write(chalk.blue('Initializing git' + '\n'));
      return Helpers.run('git', ['init']);
    }).then(function () {
      process.stdout.write(chalk.blue('Installing gem dependencies' + '\n'));
      return Helpers.run('rvm', [rvmVersion, 'exec','bundle']);
    }).then(function () {
      var railsOpts = ['new', '.', '--skip-gemfile', '--skip-bundle', '--skip-git', '--skip-javascript', '--skip'];
      process.stdout.write(chalk.blue('Initializing Rails' + '\n'));
      if (self.props.test === 'rspec') {
        railsOpts.push('--skip-test-unit');
      }
      return Helpers.run('rvm', [rvmVersion, 'exec', 'rails'].concat(railsOpts));
    }).then(function () {
      if (self.props.template !== 'erb') {
        process.stdout.write(chalk.blue('Cleanup' + '\n'));
        return Helpers.run('rm', ['app/views/layouts/application.html.erb']);
      } else {
        return Helpers.run('true');
      }
    }).then(function () {
      if (self.props.test !== 'rspec') {
        process.stdout.write(chalk.blue('Generating RSPEC scaffolding' + '\n'));
        return Helpers.run('rvm', [rvmVersion, 'exec','rails', 'generate', 'rspec:install']);
      } else {
        return Helpers.run('true');
      }
    }).then(function () {
      if (self.props.extra.indexOf('devise') !== -1) {
        process.stdout.write(chalk.blue('Running DEVISE Initializer' + '\n'));
        return Helpers.run('rvm', [rvmVersion, 'exec','rails', 'generate', 'devise:install']);
      } else {
        return Helpers.run('true');
      }
    }).then(function () {
      if (self.props.extra.indexOf('activeadmin') !== -1) {
        process.stdout.write(chalk.blue('Running Active Admin Initializer' + '\n'));
        return Helpers.run('rvm', [rvmVersion, 'exec','rails', 'generate', 'active_admin:install']);
      } else {
        return Helpers.run('true');
      }
    }).then(function () {
      if (self.props.extra.indexOf('kaminari') !== -1) {
        process.stdout.write(chalk.blue('Running Kaminari Initializer' + '\n'));
        return Helpers.run('rvm', [rvmVersion, 'exec','rails', 'generate', 'kaminari:config']);
      } else {
        return Helpers.run('true');
      }
    }).then(function () {
      process.stdout.write(chalk.blue('Activating overcommit' + '\n'));
      return Helpers.run('rvm', [rvmVersion, 'exec','overcommit', '-f']);
    }).then(function () {
      process.stdout.write(chalk.red('Don\'t forget to ' + chalk.green('rvm use .') + '!' + '\n'));
      process.stdout.write(chalk.red('Everything ready! Let\'s write some code!' + '\n'));
    }).fail(function (error) {
      console.error(error);
    });
  }
});

module.exports = RailsGenerator;
