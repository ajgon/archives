module AdminBootstrap
  module Plugins
    module Callbacks

      # Formtastic
      def formtastic_parameters options
        {:formtastic_parameters => options}
      end

      # Visibility
      def visibility_toggle value = false
        {:visibility => value}
      end

    end
  end
end