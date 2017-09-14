class Order < ApplicationRecord
  extend Embedded::Model

  embeds :price, attrs: [:currency, :amount]
  embeds :weight, attrs: [:magnitude, :quantity], class_name: 'MeasurementUnit'
end
