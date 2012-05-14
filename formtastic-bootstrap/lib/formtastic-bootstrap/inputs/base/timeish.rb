module FormtasticBootstrap
  module Inputs
    module Base
      module Timeish

        def date_input_html datetime = true
          fragment_input_html(:date, "date input-small", datetime)
        end

        def time_input_html datetime = true
          fragment_input_html(:time, "time input-mini", datetime)
        end

        def fragment_id(fragment, datetime = true)
          "#{input_html_options[:id]}" + (datetime ? "_#{fragment}" : '')
        end

        def fragment_name(fragment, datetime = true)
          "#{object_name}[#{method}]" + (datetime ? "[#{fragment}]" : '')
        end

        def fragment_input_html(fragment, klass, datetime)
          opts = input_options.merge(:prefix => object_name, :field_name => fragment_name(fragment, datetime), :default => value, :include_blank => include_blank?)
          template.class.send(:include, ActionView::Helpers::TextFieldDateHelper) # Rails with specific gem configuration gets period - this is to tame the leak (5 hours of debugging didn't help)
          template.send(:"text_field_#{fragment}", value, opts, input_html_options.merge(:id => fragment_id(fragment, datetime), :name => fragment_name(fragment, datetime), :class => klass))
        end

      end
    end
  end
end
