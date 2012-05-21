class AdminBootstrapGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  class_option :haml, :type => :boolean, :default => (Gem.available?('haml') and Gem.available?('haml-rails')), :description => "Use HAML views instead of erb"
  class_option :rspec, :type => :boolean, :default => (Gem.available?('rspec') and Gem.available?('rspec-rails')), :description => "Include RSPEC tests for resource"

  def run_tasks
    __create_model
    __create_route
    __create_controller
    __create_helper
    __create_assets
    __create_views
    __create_tests if options.rspec?
  end

  private
  def __create_model
    ARGV.unshift(name) unless ARGV.first == name
    ARGV.push('--orm=active_record') unless ARGV.find {|arg| arg.match(/^--orm/)}
    Rails::Generators.invoke("model", ARGV + ['--skip'])
  end

  def __create_route
    route "namespace :admin do resources :#{model_file.pluralize} end"
  end

  def __create_controller
    template File.join('app', 'controllers', 'admin', 'controller.rb'), File.join('app', 'controllers', 'admin', "#{controller_file}.rb")
  end

  def __create_helper
    template File.join('app', 'helpers', 'admin', 'helper.rb'), File.join('app', 'helpers', 'admin', "#{model_file.pluralize}_helper.rb")
  end

  def __create_assets
    template File.join('app', 'assets', 'javascripts', 'admin', 'asset.js.coffee'), File.join('app', 'assets', 'javascripts', 'admin', "#{model_file.pluralize}.js.coffee")
    template File.join('app', 'assets', 'stylesheets', 'admin', 'asset.css.scss'),  File.join('app', 'assets', 'stylesheets', 'admin', "#{model_file.pluralize}.css.scss" )
  end

  def __create_views
    template_extension = options.haml? ? 'haml' : 'erb'
    ['_actions', '_form', 'edit', 'index', 'new', 'show'].each do |template_name|
      template File.join('app', 'views', 'admin', '_view', "#{template_name}.html.#{template_extension}"), File.join('app', 'views', 'admin', model_file.pluralize, "#{template_name}.html.#{template_extension}")
    end
  end

  def __create_tests
    template File.join('spec', 'controllers', 'admin', 'controller_spec.rb'), File.join('spec', 'controllers', 'admin', "#{model_file.pluralize}_controller_spec.rb")
    template File.join('spec', 'helpers', 'admin', 'helper_spec.rb'), File.join('spec', 'helpers', 'admin', "#{model_file.pluralize}_helper_spec.rb")
  end

  # template privates
  def controller_class
    model_class.pluralize + 'Controller'
  end

  def controller_file
    model_file.pluralize + '_controller'
  end

  def model_class
    begin
      name.classify.constantize
      name.classify
    rescue
      name.capitalize.gsub(/_[a-z]/) {|i| i[1].upcase }
    end
  end

  def model_file
    model_class.underscore
  end

end
