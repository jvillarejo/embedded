module Embedded
  module Model
    def embedded_column_names(attr_name, attributes)
      attributes.inject({}) do |hash, a|
        hash.merge(:"#{attr_name}_#{a}" => a)
      end
    end

    def embedded 
      Embedded::Scope.new(self.all,embedded_attributes)
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