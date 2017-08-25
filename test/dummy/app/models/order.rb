class Order < ApplicationRecord
  embeds :price, attrs: [:currency, :amount]
end
