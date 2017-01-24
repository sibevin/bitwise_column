require 'bitwise_column/version'
require 'bitwise_column/i18n_handler'
require 'bitwise_column/core'
require 'bitwise_column/core_map'

module BitwiseColumn
  def self.included(base)
    base.extend ClassMethods
  end

  module ClassMethods
    def bitwise_column(col_name, bitwise_map, opts = {})
      unless bitwise_column_map.include?(col_name.to_sym)
        core = Core.new(
          col_name: col_name,
          bitwise_map: bitwise_map,
          i18n_handler: I18nHandler.new(self, col_name, opts)
        )
        bitwise_column_map << core
        define_singleton_method("#{col_name}_bitwise") do
          return core
        end
        mod = Module.new
        unless methods.include?("#{col_name}_bitwise")
          mod.module_eval do
            define_method("#{col_name}_bitwise") do
              core.to_bitwise(send(col_name))
            end

            define_method("#{col_name}_bitwise=") do |values|
              col_val = core.valid?(values) ? core.to_column(values) : send(col_name)
              if respond_to?(:write_attribute, true)
                write_attribute(col_name, col_val)
              else
                send("#{col_name}=", col_val)
              end
            end

            define_method("#{col_name}_bitwise_append") do |values|
              ori_bitwise_val = send("#{col_name}_bitwise")
              send("#{col_name}_bitwise=", ori_bitwise_val + core.normalize(values))
            end

            define_method("#{col_name}_bitwise_have?") do |values|
              ori_bitwise_val = send("#{col_name}_bitwise")
              core.have?(ori_bitwise_val, values)
            end

            define_method("#{col_name}_bitwise_text") do
              ori_bitwise_val = send("#{col_name}_bitwise")
              core.text(ori_bitwise_val)
            end
          end
        end
        include mod
      end
    end

    def bitwise_column_map
      @bitwise_column_map ||= CoreMap.new
    end
  end
end
