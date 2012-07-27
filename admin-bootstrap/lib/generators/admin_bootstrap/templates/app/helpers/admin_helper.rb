module AdminHelper
  # @param [Object] model
  def dataTables_response_for model
    columns = model.column_names(:admin => true)
    behaviour = {}

    unless params[:sSearch].blank?
      behaviour[:conditions] = "`" + columns.join("` LIKE '%#{params[:sSearch]}%' OR `") + "` LIKE '%#{params[:sSearch]}%'"
    end
    if (sorting_cols = params[:iSortingCols].to_i) > 0
      order = []
      sorting_cols.times do |i|
        i = i.to_s
        order_column = columns[params[('iSortCol_' + i)].to_i]
        order_type = params[('sSortDir_' + i)] == 'desc' ? 'DESC' : 'ASC'
        order.push "`#{order_column}` #{order_type}" unless order_column.blank?
      end
      behaviour[:order] = order.join(', ') unless order.blank?
    end
    results = model.all(behaviour.merge(:offset => params[:iDisplayStart]).merge(params[:iDisplayLength].to_i < 0 ? {} : {:limit => params[:iDisplayLength]}))

    data = results.collect do |result|
      row = {
          :DT_RowId => result.id.to_s
      }
      columns.each.with_index do |column, c|
        row[c] = result.send(column).to_s
      end
      row[columns.size] = render_to_string(:partial => 'actions', :formats => [:html], :locals => {:resource => result})
      row
    end
    return {
        :iTotalRecords => model.count,
        :iTotalDisplayRecords => model.count(behaviour),
        :sEcho => params[:sEcho],
        :aaData => data
    }
  end

  def admin_controllers
    Rails.application.routes.routes.collect do |route|
      route.defaults[:controller] if route.defaults[:controller].to_s.match(/^admin\//) and
          route.defaults[:action].to_s == 'index'
    end.compact.uniq.collect do |route|
      "#{route}_controller".classify.constantize
    end
  end

  def model_for controller_class
    begin
      return File.basename(controller_class.to_s.underscore).gsub(/_controller$/, '').classify.constantize
    rescue NameError
      return false
    end
  end

  def humanize name
    name.to_s.gsub(/([a-z])([A-Z])/) {|m| "#{m[0]} #{m[1]}"}.pluralize.humanize
  end
end
