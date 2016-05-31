module BitwiseColumn
  class CoreMap
    def initialize
      @map = {}
    end

    def <<(core)
      @map[core.col.to_sym] = core
    end

    def [](key)
      @map[key]
    end

    def include?(key)
      @map.key?(key)
    end
  end
end
