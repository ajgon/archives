require 'spec_helper'
require 'rake'

describe 'admin_bootstrap tasks' do
  DESTINATION = File.expand_path('../../tmp', File.dirname(__FILE__)) unless defined?(DESTINATION)

  def rake_resources_without item
    AdminBootstrapTask::RESOURCES.reject do |file|
      file.match(item.to_s)
    end.collect do |file|
      path_parts = ['lib', 'generators', 'admin_bootstrap', 'templates', file]
      if File.directory?(File.expand_path(File.join(*path_parts)))
        path_parts += ['**', '**', '**', '**']
        Dir.glob(File.expand_path(File.join(*path_parts)))
      else
        File.expand_path(File.join(*path_parts))
      end
    end.flatten.collect do |file|
      file.gsub(File.expand_path('lib/generators/admin_bootstrap/templates'), '')
    end
  end

  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require "tasks/admin_bootstrap_tasks"
    Rake::Task.define_task(:environment)
  end

  describe 'rake admin_bootstrap' do

    before(:all) do
      set_fake_rails_root
    end

    describe ':initialize' do
      before(:all) do
        prepare_routes
        prepare_formtastic
        @task_name = "admin_bootstrap:initialize"
        @rake[@task_name].invoke
      end

      it "should have 'environment' as a prerequisite" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      it 'should update routes' do
        File.read(File.join(DESTINATION, 'config', 'routes.rb')).should match("namespace :admin do root :to => 'dashboard#index' end")
      end

      it 'should set FormtasticBootstrap FormBuilder in Formtastic initializer' do
        File.read(File.join(DESTINATION, 'config', 'initializers', 'formtastic.rb')).should match("Formtastic::Helpers::FormHelper.builder = FormtasticBootstrap::FormBuilder")
      end

      it 'should copy all the files' do
        resources = rake_resources_without "/views/"

        resources.each do |resource|
          File.exists?(File.join(DESTINATION, resource)).should be_true
        end
      end

      after(:all) do
        clean_generated_files
      end
    end

    describe ':initialize:haml' do
      before(:all) do
        prepare_routes
        prepare_formtastic
        @task_name = "admin_bootstrap:initialize:haml"
        @rake[@task_name].invoke
      end

      it "should have 'environment' as a prerequisite" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      it 'should copy all the files with haml views included' do
        resources = rake_resources_without /\.erb$|\/shared\//

        resources.each do |resource|
          File.exists?(File.join(DESTINATION, resource)).should be_true
          File.directory?(File.join(DESTINATION, resource)).should_not be_true if File.basename(resource).include?('.')
        end
      end

      it 'should not copy any of the erb files' do
        resources = rake_resources_without(/\/shared\//).find_all {|resource| resource.match(/\.erb$/)}

        resources.each do |resource|
          File.exists?(File.join(DESTINATION, resource)).should_not be_true
        end
      end

      after(:all) do
        clean_generated_files
      end
    end

    describe ':initialize:erb' do
      before(:all) do
        prepare_routes
        prepare_formtastic
        @task_name = "admin_bootstrap:initialize:erb"
        @rake[@task_name].invoke
      end

      it "should have 'environment' as a prerequisite" do
        @rake[@task_name].prerequisites.should include("environment")
      end

      it 'should copy all the files with erb views included' do
        resources = rake_resources_without /\.haml$|\/shared\//

        resources.each do |resource|
          File.exists?(File.join(DESTINATION, resource)).should be_true
          File.directory?(File.join(DESTINATION, resource)).should_not be_true if File.basename(resource).include?('.')
        end
      end

      it 'should not copy any of the haml files' do
        resources = rake_resources_without(/\/shared\//).find_all {|resource| resource.match(/\.haml$/)}

        resources.each do |resource|
          File.exists?(File.join(DESTINATION, resource)).should_not be_true
        end
      end

      after(:all) do
        clean_generated_files
      end
    end

  end
end