module Embedded
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def embedded_column_names(attr_name, attributes)
      attributes.inject({}) do |hash, a|
        hash.merge(:"#{attr_name}_#{a}" => a)
      end
    end

    def where(opts = :chain, *rest)
      if(opts.is_a?(Hash) && opts.keys.any? { |k| embedded_attributes[k]})
        opts = opts.inject({}) do |h,(k,v)|

          if embedded_attributes[k]
            attrs = embedded_attributes[k][:attrs].inject({}) do |w,s|
              w.merge(:"#{k}_#{s}" => v.send(s))
            end

            h.merge(attrs)
          else
            h
          end
        end

        super(opts,*rest)
      else
        super
      end
    end

    def embeds(attr_name, options = {})
      cattr_accessor :embedded_attributes
      self.embedded_attributes ||= {}
      self.embedded_attributes[attr_name] = options

      attributes = options[:attrs]
      columns = embedded_column_names(attr_name,attributes)
      clazz = attr_name.to_s.camelcase.constantize

      self.send(:define_method, attr_name) do
        values = columns.inject({}) do |hash,(k,v)|
          hash.merge(v=>read_attribute(k))
        end
        clazz.new(values)
      end

      self.send(:define_method, :"#{attr_name}=") do |v|
        columns.each do |k,a|
          self.write_attribute(k, v.send(a))
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, Embedded)
