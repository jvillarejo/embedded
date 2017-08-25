class Price
  attr_reader :currency, :amount

  def initialize(values={})
    @currency = values.fetch(:currency)
    @amount = values.fetch(:amount)
  end

  def ==(other)
    return false if other.nil?
    @currency == other.currency &&
    @amount == other.amount
  end
end