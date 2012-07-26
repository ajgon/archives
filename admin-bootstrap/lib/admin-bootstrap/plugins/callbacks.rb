module AdminBootstrap
  module Plugins
    module Callbacks

      # Formtastic
      def formtastic_parameters options
        {:formtastic_parameters => options}
      end

      # Visibility
      def set_visibility value
        {:visibility => value}
      end

    end
  end
end
