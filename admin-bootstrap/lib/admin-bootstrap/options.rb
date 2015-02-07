module AdminBootstrap
  class Options

    def self.parse(&block)
      self.new.instance_eval(&block)
    end

    def method_missing name, options = {}
      options = {:enabled => true, :value => options}
      @_options = set_param :options, name, options
      results
    end

    def column name, options = nil
      __columns = set_param :columns, name, options
      @_columns = __columns unless options.nil?
      results
    end

    def options
      @_options
    end

    def columns
      @_columns
    end

    def results
      [@_columns, @_options]
    end

    private
    def set_param param, name, options = nil
      if self.__send__(param).nil?
        __opt = {}
      else
        __opt = self.__send__(param).dup
      end

      return false unless instance_variable_get("@_#{param}") or options
      return instance_variable_get("@_#{param}")[name] || {} unless options

      if __opt[name.to_sym]
        __opt[name.to_sym] = __opt[name.to_sym].merge(options.symbolize_keys)
      else
        __opt = __opt.merge(name.to_sym => options.symbolize_keys)
      end
      __opt
    end

  end
end