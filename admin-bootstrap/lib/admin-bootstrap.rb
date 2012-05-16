require "admin-bootstrap/railtie" if defined?(Rails)

module AdminBootstrap

end

# Admin columns parameters
module ActiveRecord
  class Base
    class_attribute :_admin_columns
    self._admin_columns = {}

    def self.admin_column name, options
      self._admin_columns = self._admin_columns.merge(name.to_sym => options.symbolize_keys)
    end

    def self.admin_columns
      self._admin_columns
    end

    def admin_attributes
      admin_attrs = attributes

      # Delete binary columns
      self.class.columns.find_all {|c| c.type == :binary}.collect(&:name).each do |name|
        admin_attrs.delete(name)
      end

      # Delete invisible columns
      self.class.admin_columns.each do |name, options|
        admin_attrs.delete(name.to_s) if options[:visible] === false
      end

      admin_attrs
    end

    def self.formtastic_options_for column
      formtastic_options = {}
      return formtastic_options if self.admin_columns[column].blank?
      if self.admin_columns[column][:wysiwyg]
        formtastic_options[:input_html] = {:class => 'tinymce'}
      end
      formtastic_options
    end
  end
end

# Hack f.inputs in formtastic to support special parameters without necessity to put each form element separately
module FormtasticBootstrap
  module Helpers
    module InputsHelper
      include FormtasticBootstrap::Helpers::FieldsetWrapper if defined?(FormtasticBootstrap::Helpers::FieldsetWrapper)

      def fieldset_contents_from_column_list(columns)
        columns.collect do |method|
          if @object
            if @object.class.respond_to?(:reflect_on_association)
              if (@object.class.reflect_on_association(method.to_sym) && @object.class.reflect_on_association(method.to_sym).options[:polymorphic] == true)
                raise PolymorphicInputWithoutCollectionError.new("Please provide a collection for :#{method} input (you'll need to use block form syntax). Inputs for polymorphic associations can only be used when an explicit :collection is provided.")
              end
            elsif @object.class.respond_to?(:associations)
              if (@object.class.associations[method.to_sym] && @object.class.associations[method.to_sym].options[:polymorphic] == true)
                raise PolymorphicInputWithoutCollectionError.new("Please provide a collection for :#{method} input (you'll need to use block form syntax). Inputs for polymorphic associations can only be used when an explicit :collection is provided.")
              end
            end
          end
          unless model_name.constantize.admin_columns[method.to_sym] and model_name.constantize.admin_columns[method.to_sym][:visible] === false and model_name.constantize.columns.find {|c| c.name == method.to_s}.null
            input(method.to_sym, model_name.constantize.formtastic_options_for(method.to_sym))
          end
        end
      end

    end
  end
end

# Hack to bypass another great idea of some rubygems developer.... har har
module Gem
  def self.available?(dep, *requirements)
    if Gem::Specification.respond_to?(:find_all_by_name)
      not Gem::Specification.find_all_by_name(dep).empty?
    else
      requirements = Gem::Requirement.default if requirements.empty?

      unless dep.respond_to?(:name) and dep.respond_to?(:requirement) then
        dep = Gem::Dependency.new dep, requirements
      end

      not dep.matching_specs(true).empty?
    end
  end
end