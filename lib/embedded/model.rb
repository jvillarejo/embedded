module Embedded
  module Model
    def embedded_column_names(embeddable_attr, attributes)
      attributes.inject({}) do |hash, a|
        hash.merge(:"#{embeddable_attr}_#{a}" => a)
      end
    end

    def embedded
      Embedded::Scope.new(self.all,embedded_attributes)
    end

    def embeds(embeddable_attr, options = {})
      cattr_accessor :embedded_attributes
      self.embedded_attributes ||= {}
      self.embedded_attributes[embeddable_attr] = options

      attributes = options[:attrs]
      columns = embedded_column_names(embeddable_attr,attributes)
      clazz = embeddable_attr.to_s.camelcase.constantize

      self.send(:define_method, embeddable_attr) do
        values = columns.inject({}) do |hash,(k,v)|
          hash.merge(v=>read_attribute(k))
        end
        clazz.new(values)
      end

      self.send(:define_method, :"#{embeddable_attr}=") do |v|
        columns.each do |k,a|
          self.write_attribute(k, v.send(a))
        end
      end
    end
  end
end
