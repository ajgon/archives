namespace :admin_bootstrap do
  desc "Copy all necessary assets and files for admin bootstrap, to make it look pretty"
  task :initialize => :environment do
    TEMPLATE_PATH = File.expand_path(File.join(File.dirname(__FILE__), '..', 'generators', 'admin_bootstrap', 'templates'))
    RESOURCES = %w(app/assets app/controllers/admin_controller.rb app/helpers/admin_helper.rb app/models/admin.rb app/views/shared/admin)

    files = RESOURCES.collect do |resource|
      path = File.join(TEMPLATE_PATH, resource)
      if File.directory?(path)
        Dir.glob(File.join(path, '**', '**', '**', '**')).collect do |item|
          item.gsub(Regexp.new(TEMPLATE_PATH + '/?'), '')
        end
      else
        resource
      end
    end.flatten.collect do |file|
      file unless File.directory?(File.join(TEMPLATE_PATH, file))
    end.compact

    files.each do |file|
      begin
        FileUtils.mkdir_p File.dirname(file)
        FileUtils.cp File.join(TEMPLATE_PATH, file), File.join(Rails.root, file)
        puts "#{file} copied"
      rescue
        puts "An error occurred while copying file #{file}"
      end
    end

  end

end
