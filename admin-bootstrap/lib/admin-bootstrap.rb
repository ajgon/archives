require "admin-bootstrap/railtie" if defined?(Rails)
require 'admin-bootstrap/plugins/callbacks'
require 'admin-bootstrap/plugins/base'
require "admin-bootstrap/main"
require "admin-bootstrap/extensions"
Dir.glob(File.join(File.dirname(__FILE__), 'admin-bootstrap', 'plugins', '*_plugin.rb')).each {|f| require(f)}
