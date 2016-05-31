require 'active_support/concern'

module BitwiseColumn
  module Hooks
    module SimpleFormBuilderExtension
      extend ActiveSupport::Concern

      included do
        alias_method_chain :input, :bitwise_column
        alias_method_chain :input_field, :bitwise_column
      end

      def input_with_bitwise_column(attribute_name, options={}, &block)
        add_input_options_for_bitwise_column(attribute_name, options)
        input_without_bitwise_column(attribute_name, options, &block)
      end

      def input_field_with_bitwise_column(attribute_name, options={})
        add_input_options_for_bitwise_column(attribute_name, options)
        input_field_without_bitwise_column(attribute_name, options)
      end

      private

      def add_input_options_for_bitwise_column(attribute_name, options)
        klass = object.class
        if klass.respond_to?(:bitwise_core_map) && (core = klass.bitwise_core_map[attribute_name])
          options[:collection] ||= core.input_options(options)
          if options[:as] != :check_boxes
            options[:input_html] = options.fetch(:input_html, {}).merge(:multiple => true)
          end
        end
      end
    end
  end
end

::SimpleForm::FormBuilder.send :include, Enumerize::Hooks::SimpleFormBuilderExtension
