require 'bitwise_column/version'
require 'bitwise_column/i18n_handler'
require 'bitwise_column/core'
require 'bitwise_column/core_map'

module BitwiseColumn
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def bitwise_column(col_name, bitwise_map)
      unless bitwise_core_map.include?(col_name.to_sym)
        bitwise_core_map << Core.new(col_name: col_name, bitwise_map: bitwise_map)
        mod = Module.new
        unless methods.include?("#{col_name}_bitwise")
          mod.module_eval <<-RUBY, __FILE__, __LINE__ + 1
            def #{col_name}_bitwise
              self.class.bitwise_core_map[:#{col_name}].bitwise_value(self)
            end

            def #{col_name}_bitwise=(values)
              col_value = self.class.bitwise_core_map[:'#{col_name}'].assign(self, values)
              if respond_to?(:write_attribute, true)
                write_attribute(:'#{col_name}', col_value)
              else
                @#{col_name} = col_value
              end
            end

            def #{col_name}_bitwise_append(values)
              col_value = self.class.bitwise_core_map[:'#{col_name}'].append(self, values)
              if respond_to?(:write_attribute, true)
                write_attribute(:'#{col_name}', col_value)
              else
                @#{col_name} = col_value
              end
            end

            def #{col_name}_bitwise_have?(values)
              self.class.bitwise_core_map[:#{col_name}].have?(self, values)
            end

            def #{col_name}_bitwise_text
              self.class.bitwise_core_map[:#{col_name}].text(self)
            end

            def #{col_name}_bitwise_options(opts = {})
              self.class.bitwise_core_map[:#{col_name}].input_options(opts)
            end
          RUBY
        end
        include mod
      end
    end

    def bitwise_core_map
      @bitwise_core_map ||= CoreMap.new
    end
  end
end
