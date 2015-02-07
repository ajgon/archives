module AdminHelper
  def admin_controllers without_defaults = true
    Rails.application.routes.routes.collect do |route|
      route.defaults[:controller] if route.defaults[:controller].to_s.match(/^admin\//) and
          route.defaults[:action].to_s == 'index'
    end.compact.uniq.collect do |route|
      "#{route}_controller".classify.constantize
    end - (without_defaults ? [Admin::DashboardController] : [])
  end

  def model_for controller_class
    begin
      return File.basename(controller_class.to_s.underscore).gsub(/_controller$/, '').classify.constantize
    rescue NameError
      return false
    end
  end

  def admin_parse_value result, column
    AdminBootstrap::DataTable.parse_value(result, column)
  end

  def humanize name
    name.to_s.gsub(/([a-z])([A-Z])/) {|m| "#{m[0]} #{m[1]}"}.pluralize.humanize
  end
end
