module Embedded
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
    def acts_as_yaffle(options = {})
      # your code will go here
    end
  end
end

ActiveRecord::Base.send(:include, Embedded)
