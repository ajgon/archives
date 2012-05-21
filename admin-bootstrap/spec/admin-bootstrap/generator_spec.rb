require 'spec_helper'
require 'generators/admin_bootstrap/admin_bootstrap_generator'
require "generator_spec/test_case"
require 'rails/generators/active_record/model/model_generator'

module ActiveRecord
  module Generators
    class ModelGenerator
      def create_model_file
        template 'model.rb', File.join('tmp/app/models', class_path, "#{file_name}.rb")
      end
    end
  end
end # Because ActiveRecord is not checking rails root and putting generated model straight to the current directory

describe AdminBootstrapGenerator do
  NAME        = 'test_model'
  DESTINATION = File.expand_path('../../tmp', File.dirname(__FILE__)) unless defined?(DESTINATION)
  VIEWS       = ['_actions', '_form', 'edit', 'index', 'new', 'show']

  context 'without options' do
    include GeneratorSpec::TestCase
    destination DESTINATION
    arguments [NAME]

    before(:all) do
      set_fake_rails_root
      prepare_destination
      prepare_routes
      run_generator
    end

    it 'should create model' do
      model_file = File.join(DESTINATION, 'app', 'models', NAME + '.rb')
      File.exists?(model_file).should be_true
      File.read(model_file).should match("#{NAME.classify} < ActiveRecord::Base")
    end

    it 'should update routes' do
      File.read(File.join(DESTINATION, 'config', 'routes.rb')).should match("namespace :admin do resources :#{NAME.pluralize} end")
    end

    it 'should create controller' do
      controller_file = File.join(DESTINATION, 'app', 'controllers', 'admin', NAME.pluralize + '_controller.rb')
      File.exists?(controller_file).should be_true
      File.read(controller_file).should match("Admin::#{NAME.classify.pluralize}Controller < AdminController")
    end

    it 'should create helper' do
      helper_file = File.join(DESTINATION, 'app', 'helpers', 'admin', NAME.pluralize + '_helper.rb')
      File.exists?(helper_file).should be_true
      File.read(helper_file).should match("module Admin::#{NAME.classify.pluralize}Helper")
    end

    it 'should create assets' do
      asset_js  = File.join(DESTINATION, 'app', 'assets', 'javascripts', 'admin', NAME.pluralize + '.js.coffee')
      asset_css = File.join(DESTINATION, 'app', 'assets', 'stylesheets', 'admin', NAME.pluralize + '.css.scss')
      File.exists?(asset_js).should be_true
      File.exists?(asset_css).should be_true
    end

    after(:all) do
      clean_generated_files
    end

  end

  context 'with haml set' do
    include GeneratorSpec::TestCase
    destination DESTINATION
    arguments [NAME, '--haml']

    before(:all) do
      set_fake_rails_root
      prepare_destination
      prepare_routes
      run_generator
    end

    it 'should copy haml views' do
      VIEWS.each do |view|
        File.exists?(File.join(DESTINATION, 'app', 'views', 'admin', "#{NAME.pluralize}", "#{view}.html.haml")).should be_true
      end
    end

    it 'should not copy erb views' do
      VIEWS.each do |view|
        File.exists?(File.join(DESTINATION, 'app', 'views', 'admin', "#{NAME.pluralize}", "#{view}.html.erb")).should_not be_true
      end
    end

    after(:all) do
      clean_generated_files
    end

  end

  context 'with haml unset' do
    include GeneratorSpec::TestCase
    destination DESTINATION
    arguments [NAME, '--no-haml']

    before(:all) do
      set_fake_rails_root
      prepare_destination
      prepare_routes
      run_generator
    end

    it 'should not copy haml views' do
      VIEWS.each do |view|
        File.exists?(File.join(DESTINATION, 'app', 'views', 'admin', "#{NAME.pluralize}", "#{view}.html.haml")).should_not be_true
      end
    end

    it 'should copy erb views' do
      VIEWS.each do |view|
        File.exists?(File.join(DESTINATION, 'app', 'views', 'admin', "#{NAME.pluralize}", "#{view}.html.erb")).should be_true
      end
    end

    after(:all) do
      clean_generated_files
    end

  end

  context 'with rspec set' do
    include GeneratorSpec::TestCase
    destination DESTINATION
    arguments [NAME, '--rspec']

    before(:all) do
      set_fake_rails_root
      prepare_destination
      prepare_routes
      run_generator
    end

    it 'should create specs for controller' do
      spec_file = File.join(DESTINATION, 'spec', 'controllers', 'admin', NAME.pluralize + '_controller_spec.rb')
      File.exists?(spec_file).should be_true
      File.read(spec_file).should match("Admin::#{NAME.classify.pluralize}Controller")
      File.read(spec_file).should match('it_should_behave_like "admin resource"')
    end

    after(:all) do
      clean_generated_files
    end

  end

  context 'with rspec unset' do
    include GeneratorSpec::TestCase
    destination DESTINATION
    arguments [NAME, '--no-rspec']

    before(:all) do
      set_fake_rails_root
      prepare_destination
      prepare_routes
      run_generator
    end

    it 'should not create specs for controller' do
      spec_file = File.join(DESTINATION, 'spec', 'controllers', 'admin', NAME.pluralize + '_controller_spec.rb')
      File.exists?(spec_file).should_not be_true
    end

    after(:all) do
      clean_generated_files
    end

  end

end
