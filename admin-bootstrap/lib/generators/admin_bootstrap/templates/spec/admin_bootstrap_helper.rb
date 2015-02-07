class ActionController::Base
  def self.extract_resource
    begin
      return File.basename(self.to_s.underscore).gsub(/_controller$/, '').classify.constantize
    rescue NameError
      return false
    end
  end
end

def parse_json source
  ActiveSupport::JSON.decode source
end

# Temporary hack to avoid DEPRECTAION warnings
# TODO: check temporary to see if it is resolved in nevest ActiveRecord

module ActiveSupport
  # Look for and parse json strings that look like ISO 8601 times.
  mattr_accessor :parse_json_times

  module JSON
    class << self
      def decode(json, options ={})
        data = MultiJson.load(json, options)
        if ActiveSupport.parse_json_times
          convert_dates_from(data)
        else
          data
        end
      end
    end
  end
end