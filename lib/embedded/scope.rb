module Embedded
  class Scope
    def initialize(scope,attributes)
      @attributes = attributes
      @scope = scope
    end

    def embedded_attributes
      embedded_attributes_for(nil)
    end

    def embedded_attributes_for(value = nil)
      @attributes.inject({}) do |a,(embeddable_attr,v)|
        v[:attrs].inject(a) do |hash,attr|
          hash.merge(:"#{embeddable_attr}_#{attr}" => value ? value.send(attr) : nil)
        end
      end
    end

    def where(opts = :chain, *rest)
      opts = opts.inject({}) do |h,(k,v)|
        if @attributes[k]
          h.merge(embedded_attributes_for(v))
        else
          h
        end
      end

      @scope.where(opts, *rest)
    end
  end
end
