module AdminBootstrap
  class Tasks < Rails::Railtie
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__),'../tasks/*.rake')].each { |f| load f }
    end
  end

  class Initializer < Rails::Engine
    initializer 'admin_bootstrap.update_admin_defaults_in_models', :after=>'finisher_hook' do |app|
      Dir.glob(File.join(Rails.root, 'app', 'models', '*.rb')).each do |controller_file|
        require controller_file
      end unless Rails.env == 'production'
      ActiveRecord::Base.subclasses.each do |model|
        model.call_defaults
      end
    end
  end
end