module AdminHelper
  # @param [Object] model
  def dataTables_response_for model
    columns = model.columns.find_all {|c| c.type != :binary}.collect {|c| c.name}
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

  def get_columns model
    model.columns.find_all {|c| c.type != :binary}
  end
end
