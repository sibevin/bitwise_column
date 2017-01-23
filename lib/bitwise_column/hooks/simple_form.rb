require 'active_support/concern'

module BitwiseColumn
  module Hooks
    module SimpleFormBuilderExtension
      def input(attribute_name, options = {}, &block)
        add_input_options_for_bitwise_column_attribute(attribute_name, options)
        super(attribute_name, options, &block)
      end

      def input_field(attribute_name, options = {})
        add_input_options_for_bitwise_column_attribute(attribute_name, options)
        super(attribute_name, options)
      end

      private

      def add_input_options_for_bitwise_column_attribute(attribute_name, options)
        klass = object.class
        if klass.respond_to?(:bitwise_core_map) && (core = klass.bitwise_core_map[attribute_name])
          options[:collection] ||= core.input_options
        end
      end
    end
  end
end

::SimpleForm::FormBuilder.send :prepend, BitwiseColumn::Hooks::SimpleFormBuilderExtension
