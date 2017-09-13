class Order < ApplicationRecord
  extend Embedded::Model

  embeds :price, attrs: [:currency, :amount]
end
