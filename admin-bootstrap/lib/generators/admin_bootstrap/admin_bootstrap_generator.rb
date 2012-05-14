class AdminBootstrapGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)
  class_option :haml, :type => :boolean, :default => (Gem.available?('haml') and Gem.available?('haml-rails')), :description => "Use HAML views instead of erb"
  class_option :rspec, :type => :boolean, :default => (Gem.available?('rspec') and Gem.available?('rspec-rails')), :description => "Include RSPEC tests for resource"

  def run_tasks
    __create_model
    __create_route
    __create_controller
    __create_views
    __create_tests if options.rspec?
  end

  private
  def __create_model
    Rails::Generators.invoke("model", ARGV + ['--skip'])
  end

  def __create_route
    route "namespace :admin do resources :#{name.classify.constantize.table_name} end"
  end

  def __create_controller
    template File.join('app', 'controllers', 'admin', 'controller.rb'), File.join('app', 'controllers', 'admin', "#{controller_file_name}.rb")
  end

  def __create_views
    template_extension = options.haml? ? 'haml' : 'erb'
    ['_actions', '_form', 'edit', 'index', 'new', 'show'].each do |template_name|
      template File.join('app', 'views', 'admin', '_view', "#{template_name}.html.#{template_extension}"), File.join('app', 'views', 'admin', raw_file_name, "#{template_name}.html.#{template_extension}")
    end
  end

  def __create_tests
    template File.join('spec', 'controllers', 'admin', 'controller.rb'), File.join('spec', 'controllers', 'admin', "#{raw_file_name}_spec.rb")
  end

  # template privates
  def raw_file_name
    name.classify.constantize.table_name
  end

  def raw_class_name
    raw_file_name.capitalize.gsub(/_[a-z]/) {|i| i[1].upcase}
  end

  def controller_file_name
    raw_file_name + '_controller'
  end

  def controller_class_name
    raw_class_name + 'Controller'
  end

end
