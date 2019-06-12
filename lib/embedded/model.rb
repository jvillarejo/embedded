module Embedded
  module Model
    ScopeMethod = ActiveRecord::VERSION::MAJOR >= 4 ? :all.freeze : :scoped.freeze

    def embedded_column_names(embeddable_attr, attributes)
      if attributes.is_a?(Array)
        attributes.inject({}) do |hash, a|
          hash.merge(:"#{embeddable_attr}_#{a}" => a)
        end
      elsif attributes.is_a?(Hash)
        attributes.invert
      else
        raise ArgumentError.new('invalid attributes')
      end
    end

    def embedded
      Embedded::Scope.new(send(ScopeMethod),embedded_attributes)
    end

    def embedded_attributes
      @embedded_attributes ||= {}
    end

    def embeds(embeddable_attr, options = {})

      # add comment for test
      self.embedded_attributes[embeddable_attr] = options

      attributes = options[:attrs]
      columns = embedded_column_names(embeddable_attr,attributes)
      clazz = options[:class_name] ? options[:class_name].constantize : embeddable_attr.to_s.camelcase.constantize

      self.send(:define_method, embeddable_attr) do
        values = columns.inject({}) do |hash,(k,v)|
          hash.merge(v=>read_attribute(k))
        end
        clazz.new(values)
      end

      self.send(:define_method, :"#{embeddable_attr}=") do |v|
        if v.is_a?(clazz)
          columns.each do |k,a|
            write_attribute(k, v.send(a))
          end
        elsif v.is_a?(Hash)
          columns.each do |k,a|
            write_attribute(k, v[a])
          end
        else
          raise ArgumentError.new("invalid class. #{clazz.to_s} or Hash was expected")
        end
      end
    end
  end
end
