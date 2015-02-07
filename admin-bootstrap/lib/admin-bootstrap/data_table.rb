module AdminBootstrap
  class DataTable

    attr_reader :data

    def initialize model_klass, params, &block
      @model = model_klass
      @columns = @model.column_names(:admin => true)
      @params = params
      @behaviour = {}
      @results = nil

      case ActiveRecord::Base.connection_config[:adapter]
        when 'mysql', 'mysql2'
          @column_escape = '`'
        when 'postgresql'
          @column_escape = '"'
        else
          @column_escape = ''
      end

      search
      sort
      pagination

      @data = data &block
    end

    def search
      unless @params[:sSearch].blank?
        @behaviour[:conditions] = @column_escape + (@columns && @model.column_names).join("#{@column_escape} LIKE '%#{@params[:sSearch]}%' OR #{@column_escape}") + "#{@column_escape} LIKE '%#{@params[:sSearch]}%'"
      end
    end

    def sort
      if (sorting_cols = @params[:iSortingCols].to_i) > 0
        order = []
        sorting_cols.times do |i|
          i = i.to_s
          order_column = @columns[@params[('iSortCol_' + i)].to_i]
          order_type = @params[('sSortDir_' + i)] == 'desc' ? 'DESC' : 'ASC'
          order.push "#{@column_escape}#{order_column}#{@column_escape} #{order_type}" unless order_column.blank?
        end
        @behaviour[:order] = order.join(', ') unless order.blank?
      end
    end

    def pagination
      @behaviour[:offset] = @params[:iDisplayStart]
      @behaviour[:limit] = @params[:iDisplayLength] if @params[:iDisplayLength].to_i > 0
    end

    def query
      @results ||= @model.all(@behaviour)
    end
    alias :results :query

    def query!
      @results = @model.all(@behaviour)
    end

    def count
      @model.count(@behaviour)
    end

    def total
      @model.count
    end

    def data &block
      return @data if @data
      data! &block
    end

    def data!
      data = results.collect do |result|
        row = {
            :DT_RowId => result.id.to_s
        }

        @columns.each.with_index do |column, c|
          row[c] = self.class.parse_value result, column
        end
        row[@columns.size] = yield(result)
        row
      end

      @data = {
          :iTotalRecords => total,
          :iTotalDisplayRecords => count,
          :sEcho => @params[:sEcho],
          :aaData => data
      }
    end

    def to_json options = {}
      data.to_json
    end

    def self.parse_value result, column
      admin_column = result.class.admin_column(column.to_sym)

      value = result.send(column).to_s
      itemclass = admin_column[:class] ? " class=\"#{admin_column[:class]}\"" : ''
      content = ''
      if !(col = result.class.columns.find {|c| c.name == column.to_s}) or col.type != :text
        content = ' data-value="' + value.gsub(/&/, "&amp;").gsub(/\"/, "&quot;").gsub(/>/, "&gt;").gsub(/</, "&lt;") + '"'
      end

      if admin_column[:value]
        value = admin_column[:value].call(value)
      end

      value = "<div#{itemclass}#{content}>#{value}</div>"
    end

  end
end