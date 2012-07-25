require "action_controller/railtie"
require 'active_model'
require 'rspec_tag_matchers'
require 'active_record'
require 'active_record/fixtures'

# Create a simple rails application for use in testing the viewhelper
module AdminBoostrapTest
  class Application < Rails::Application
    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"
    config.active_support.deprecation = :stderr
  end
end
AdminBoostrapTest::Application.initialize!

module ActiveRecord
  class Base
    def self.configurations
    end
  end
end

require 'rspec/rails'

class ::Item
  extend ActiveModel::Naming if defined?(ActiveModel::Naming)
  include ActiveModel::Conversion if defined?(ActiveModel::Conversion)

  extend AdminBootstrap::ClassMethods::ActiveRecord
  include AdminBootstrap::InstanceMethods::ActiveRecord
  class_attribute :_admin_columns, :_admin_options

  def id
  end

  def persisted?
  end
end

module FormtasticSpecHelper
  include ActionController::RecordIdentifier
  include ActionView::Context if defined?(ActionView::Context)
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::UrlHelper

  include Formtastic::Helpers::FormHelper

  def item_path(*args); "/items/1"; end

  def self.included(base)
    base.class_eval do

      attr_accessor :output_buffer

      def protect_against_forgery?
        false
      end

      def _helpers
        FakeHelpersModule
      end

    end
  end
end

RSpec.configure do |config|
  config.include RspecTagMatchers
  config.mock_with :rspec
end