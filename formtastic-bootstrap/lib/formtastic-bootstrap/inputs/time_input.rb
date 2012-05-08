module FormtasticBootstrap
  module Inputs
    class TimeInput < Formtastic::Inputs::TimeInput
      include Base
      include Base::Stringish
      include Base::Timeish

      def to_html
        generic_input_wrapping do
          time_input_html false
        end
      end

    end
  end
end