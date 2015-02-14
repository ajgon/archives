require 'admin-bootstrap/data_table'
require 'admin-bootstrap/options'

module AdminBootstrap

  module Plugins
  end

  module ClassMethods
    module ActiveRecord

      def admin &block
        self._admin_columns, self._admin_options = AdminBootstrap::Options.parse(&block)
      end

      def admin_option name, options = {}
        options = {:enabled => true, :value => options}
        self._admin_options = set_admin_param :admin_options, name, options
      end

      def admin_column name, options = nil
        __admin_columns = set_admin_param :admin_columns, name, options
        self._admin_columns = __admin_columns unless options.nil?
        __admin_columns
      end

      def admin_options
        self._admin_options
      end

      def admin_columns
        self._admin_columns
      end

      def admin_option_value name
        if admin_options[name] and admin_options[name][:enabled]
          admin_options[name][:value]
        end
      end

      def admin_plugins for_column, filter = nil
        plugins = Array(admin_column(for_column.to_sym)).collect do |param, value|
          AdminBootstrap::Plugins::Base.call(self, for_column, param, value)
        end
        if filter
          plugins = plugins.collect {|i| i[filter]}.compact
          plugin_item = plugins.first
          if !!plugin_item == plugin_item # is boolean?
            plugins = plugins.inject('&')
          elsif plugin_item.is_a?(Array)
            plugins = plugins.inject(:+)
          elsif plugin_item.is_a?(Hash)
            plugins = plugins.inject(:deep_merge)
          else
            plugins = plugins.inject(:+)
          end
        end
        plugins
      end

      def call_defaults
        self._admin_options ||= {}
        self._admin_columns ||= {}
        AdminBootstrap::Plugins::Base.defaults.each_value do |callback|
          callback.call(self)
        end
      end

      def columns options = {}
        @columns ||= connection.schema_cache.columns[table_name].map do |col|
          col = col.dup
          col.primary = (col.name == primary_key)
          col
        end
        if options[:admin]
          _columns = @columns.map do |c|
            admin_plugins(c.name.to_sym)
            c.name.to_sym
          end
          extra_columns = admin_columns.keys - _columns
          extra_columns.each do |extra_column|
            admin_plugins extra_column
            extra_options = admin_columns[extra_column]
            _columns[_columns.index(extra_options[:after]) + 1, 0] = extra_column if extra_options[:after]
            _columns[_columns.index(extra_options[:before]), 0]    = extra_column if extra_options[:before]
            _columns[_columns.index(extra_options[:replace])]      = extra_column if extra_options[:replace]
          end
          _columns = _columns - admin_columns.collect {|k, v| k if v[:visible] === false}.compact
          _columns = Array(admin_option_value(:columns_order)) | _columns if admin_option_value(:columns_order)
          @columns_admin ||= _columns.collect do |admin_column|
            @columns.find {|column| column.name == admin_column.to_s} || @columns.first.class.new(admin_column.to_s, nil, 'string', true)
          end
          return @columns_admin
        end
        return @columns
      end

      def columns_hash options = {}
        unless options[:admin]
          @columns_hash ||= Hash[columns.map { |c| [c.name, c] }]
        else
          @columns_admin_hash ||= Hash[columns(:admin => true).map { |c| [c.name, c] }]
        end
      end

      def column_defaults options = {}
        unless options[:admin]
          @column_defaults ||= Hash[columns.map { |c| [c.name, c.default] }]
        else
          @column_admin_defaults ||= Hash[columns(:admin => true).map { |c| [c.name, c.default] }]
        end
      end

      def column_names options = {}
        unless options[:admin]
          @column_names ||= columns.map { |column| column.name }
        else
          @column_admin_names ||= columns(:admin => true).map { |column| column.name }
        end
      end

      def content_columns options = {}
        unless options[:admin]
          @content_columns ||= columns.reject { |c| c.primary || c.name =~ /(_id|_count)$/ || c.name == inheritance_column }
        else
          @content_admin_columns ||= columns(:admin => true).reject { |c| c.primary || c.name =~ /(_id|_count)$/ || c.name == inheritance_column }
        end
      end

      def nested_tables
        reflect_on_all_associations.find_all do |reflection|
          nested_attributes_options.keys.include?(reflection.table_name.to_sym) and reflection.macro == :has_many and reflect_on_association(reflection.table_name.to_sym)
        end.collect do |reflection|
          reflection.table_name.to_sym
        end.uniq
      end

      def admin_nested_tables
        nested_tables - Array(admin_option_value(:disable_nested))
      end

      private
      def set_admin_param param, name, options = nil
        if self.__send__(param).nil?
          __opt = {}
        else
          __opt = self.__send__(param).dup
        end
        return __send__('_' + param.to_s)[name] || {} unless options
        if __opt[name.to_sym]
          __opt[name.to_sym] = __opt[name.to_sym].merge(options.symbolize_keys)
        else
          __opt = __opt.merge(name.to_sym => options.symbolize_keys)
        end
        __opt
      end

    end
  end

  module InstanceMethods
    module ActiveRecord

      def attributes options = {}
        if options[:admin]
          Hash[self.class.column_names(:admin=>true).collect {|column| [column, self.send(column)]}]
        else
          @attributes
        end
      end

      def call_defaults
        self.class.call_defaults
      end

    end
  end
end
