# Admin columns parameters
module ActiveRecord
  class Base
    extend AdminBootstrap::ClassMethods::ActiveRecord
    include AdminBootstrap::InstanceMethods::ActiveRecord

    class_attribute :_admin_columns
  end
end

# Hack f.inputs in formtastic to support special parameters without necessity to put each form element separately
module FormtasticBootstrap
  module Helpers
    module InputsHelper
      include FormtasticBootstrap::Helpers::FieldsetWrapper if defined?(FormtasticBootstrap::Helpers::FieldsetWrapper)

      def fieldset_contents_from_column_list(columns)
        columns = (model_name.constantize.column_names(:admin => true).map(&:to_sym) + columns).uniq - Formtastic::Helpers::InputsHelper::SKIPPED_COLUMNS - [:id]
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
          visibility = model_name.constantize.admin_plugins(method.to_sym, :visibility)
          unless !visibility.nil? and visibility === false and model_name.constantize.columns.find {|c| c.name == method.to_s}.null
            formtastic_parameters = model_name.constantize.admin_plugins(method.to_sym, :formtastic_parameters) || {}
            [:input_html, :wrapper_html].each do |fp|
              formtastic_parameters_table = (formtastic_parameters[fp] || {}).map do |k, v|
                begin
                  [k, (v.index('@object') == 0 ? eval(v) : v)]
                rescue
                  [k,v]
                end
              end
              formtastic_parameters[fp] = Hash[formtastic_parameters_table]
            end
            input(method.to_sym, formtastic_parameters)
          end
        end
      end

    end
  end
end

#Hack to bypass another great idea of some rubygems developer.... har har
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
