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
      @attributes.inject({}) do |a,(h,v)| 
        v[:attrs].inject(a) do |hash,attr| 
          hash.merge(:"#{h}_#{attr}" => value ? value.send(attr) : nil)
        end
      end
    end

    def where(opts = :chain, *rest)
      if(opts.is_a?(Hash) && opts.keys.any? { |k| @attributes[k]})
        opts = opts.inject({}) do |h,(k,v)|

          if @attributes[k]
            h.merge(embedded_attributes_for(v))
          else
            h
          end
        end

        if @scope.where_values_hash.keys.any? {|k| embedded_attributes.keys.include?(k.to_sym)}
          scope_hash_non_emmbeded_values = @scope.where_values_hash
                                                 .select do |k,v| 
                                                    !embedded_attributes[k.to_sym]
                                                  end
            
          opts = opts.merge(scope_hash_non_emmbeded_values)
          
          @scope.unscope(:where)
                .where(opts,*rest)            
        else
          @scope.where(opts,*rest)
        end
      else
        @scope.where(opts, *rest)
      end
    end
  end
end