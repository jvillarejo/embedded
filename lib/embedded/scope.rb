module Embedded
  class Scope
    def initialize(scope,attributes)
      @attributes = attributes
      @scope = scope
    end

    def embedded_attributes_for(embeddable_attr, value = nil)
      @attributes[embeddable_attr][:attrs].inject({}) do |a,attr|
        a.merge(:"#{embeddable_attr}_#{attr}" => value ? value.send(attr) : nil)
      end
    end

    def where(opts = :chain, *rest)
      opts = opts.inject({}) do |h,(k,v)|
        if @attributes[k]
          h.merge(embedded_attributes_for(k,v))
        else
          h
        end
      end

      self.class.new(@scope.where(opts, *rest), @attributes)
    end

    def method_missing(method, *args, &block)
      @scope.send(method,*args,&block)
    end
  end
end
