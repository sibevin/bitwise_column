module BitwiseColumn
  class Core
    def initialize(col_name:, bitwise_map:)
      @map = bitwise_map
      @col_name = col_name.to_sym
    end

    def col
      @col_name
    end

    def append(target_klass, values)
      values = symbolize(values)
      bitwise_vals = read_col(target_klass)
      if values.is_a?(Array)
        bitwise_vals = (bitwise_vals + values)
      else
        bitwise_vals = (bitwise_vals << values.to_sym)
      end
      return_col_value(bitwise_vals, target_klass)
    end

    def assign(target_klass, values)
      values = symbolize(values)
      bitwise_vals = read_col(target_klass)
      if values.is_a?(Array)
        bitwise_vals = values
      else
        bitwise_vals = [values.to_sym]
      end
      return_col_value(bitwise_vals, target_klass)
    end

    def have?(target_klass, values)
      values = symbolize(values)
      bitwise_vals = read_col(target_klass)
      if values.is_a?(Array)
        is_all_include = true
        values.each do |v|
          unless bitwise_vals.include?(v)
            is_all_include = false
            break
          end
        end
        return is_all_include
      else
        return bitwise_vals.include?(values.to_sym)
      end
    end

    def bitwise_value(target_klass)
      read_col(target_klass)
    end

    def text(target_klass)
      bitwise_vals = read_col(target_klass)
      i18n_handler = BitwiseColumn::I18nHandler.new(target_klass, @col_name)
      bitwise_vals.map { |v| i18n_handler.translate(v) }
    end

    def input_options(opts = {})
      values = if opts.empty?
                 @map.keys
               else
                 fail ArgumentError, 'Options cannot have both :only and :except' if opts[:only] && opts[:except]
                 only = Array(opts[:only]).map(&:to_s)
                 except = Array(opts[:except]).map(&:to_s)
                 @map.keys.reject do |value|
                   if opts[:only]
                     !only.include?(value)
                   elsif opts[:except]
                     except.include?(value)
                   end
                 end
      end
      i18n_handler = BitwiseColumn::I18nHandler.new(target_klass, @col_name)
      values.map { |v| [i18n_handler.translate(v), v.to_s] }
    end

    private

    def get_col_value(target_klass)
      target_klass.send(@col_name)
    end

    def symbolize(values)
      values.is_a?(Array) ? values.map(&:to_sym) : values.to_sym
    end

    def normailize(bitwise_val)
      bitwise_val.uniq.sort
    end

    def valid?(bitwise_val)
      is_valid = true
      bitwise_val.each do |bv|
        if @map[bv].nil?
          is_valid = false
          break
        end
      end
      is_valid
      # raise ArgumentError, 'Invalid bitwise value' unless is_valid
    end

    def read_col(target_klass)
      col_to_bitwise_value(get_col_value(target_klass))
    end

    def col_to_bitwise_value(col_val)
      result = []
      @map.each do |bit_key, bit_value|
        result << bit_key if (col_val & 2**(bit_value - 1)) != 0
      end
      result
    end

    def bitwise_to_col_value(bitwise_val)
      valid?(bitwise_val)
      result = 0
      bitwise_val.each do |bv|
        result |= 2**(@map[bv] - 1) if @map[bv]
      end
      result
    end

    def return_col_value(bitwise_val, target_klass)
      bitwise_val = normailize(bitwise_val)
      if valid?(bitwise_val)
        return bitwise_to_col_value(bitwise_val)
      else
        return get_col_value(target_klass)
      end
    end
  end
end
