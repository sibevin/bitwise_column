module BitwiseColumn
  class Core
    def initialize(col_name:, bitwise_map:, i18n_handler: nil)
      @map = bitwise_map
      @col_name = col_name.to_sym
      @i18n_handler = i18n_handler
    end

    def col
      @col_name
    end

    def have?(current_values, given_values)
      current_values = unify_bitwise(current_values)
      given_values = unify_bitwise(given_values)
      is_all_included = true
      given_values.each do |g_val|
        unless current_values.include?(g_val)
          is_all_included = false
          break
        end
      end
      is_all_included
    end

    def text(bitwise_vals)
      bitwise_vals = unify_bitwise(bitwise_vals)
      bitwise_vals.map { |v| @i18n_handler.translate(v) }
    end

    def keys
      @map.keys
    end

    def to_column(given_bitwise_val)
      bitwise_to_col_value(unify_bitwise(given_bitwise_val))
    end

    def to_bitwise(given_col_val)
      col_to_bitwise_value(given_col_val)
    end

    def mapping
      @map
    end

    def input_options(opts = {})
      values = if opts.empty?
                 @map.keys
               else
                 fail ArgumentError, 'Options cannot have both :only and :except' if opts[:only] && opts[:except]
                 only = Array(opts[:only]).map(&:to_s)
                 except = Array(opts[:except]).map(&:to_s)
                 @map.keys.select do |value|
                   if opts[:only]
                     only.include?(value)
                   elsif opts[:except]
                     !except.include?(value)
                   end
                 end
      end
      values.map { |v| [@i18n_handler.translate(v), v.to_s] }
    end

    def valid?(bitwise_val)
      bitwise_val = unify_bitwise(bitwise_val)
      is_valid = true
      bitwise_val.each do |bv|
        if @map[bv].nil?
          is_valid = false
          break
        end
      end
      is_valid
    end

    def unify_bitwise(bitwise_val)
      normailize(arrayize(symbolize(bitwise_val)))
    end

    private

    def symbolize(bitwise_val)
      return nil if bitwise_val.nil?
      bitwise_val.is_a?(Array) ? bitwise_val.map(&:to_sym) : bitwise_val.to_sym
    end

    def normailize(bitwise_val)
      bitwise_val = bitwise_val.uniq
      invalid_col_value = @map.size + 1
      bitwise_val.sort { |a, b| (@map[a] || invalid_col_value) <=> (@map[b] || invalid_col_value) }
    end

    def arrayize(bitwise_val)
      return [] if bitwise_val.nil?
      bitwise_val.is_a?(Array) ? bitwise_val : [bitwise_val.to_sym]
    end

    def col_to_bitwise_value(col_val)
      result = []
      unless col_val.nil?
        @map.each do |bit_key, bit_value|
          result << bit_key if (col_val & 2**(bit_value - 1)) != 0
        end
      end
      result
    end

    def bitwise_to_col_value(bitwise_val)
      result = 0
      bitwise_val.each do |bv|
        result |= 2**(@map[bv] - 1) if @map[bv]
      end
      result
    end
  end
end
