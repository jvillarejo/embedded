module Embedded
  class Scope
    def initialize(scope,attributes)
      @attributes = attributes
      @scope = scope
    end

    def embedded_attributes_for(embeddable_attr, value = nil)
      attrs = @attributes[embeddable_attr][:attrs]

      if attrs.is_a?(Array)
        attrs.inject({}) do |a,attr|
          a.merge(:"#{embeddable_attr}_#{attr}" => value ? value.send(attr) : nil)
        end
      elsif attrs.is_a?(Hash)
        attrs.inject({}) do |a,(attr,column)| 
          a.merge(column => value ? value.send(attr) : nil)
        end
      end
    end

    def where(opts = :chain, *rest)
      if opts.is_a?(Hash)
        opts = opts.inject({}) do |h,(k,v)|
          if @attributes[k]
            h.merge(embedded_attributes_for(k,v))
          else
            h
          end
        end
      end

      self.class.new(@scope.where(opts, *rest), @attributes)
    end

    def method_missing(method, *args, &block)
      @scope.send(method,*args,&block)
    end
  end
end
