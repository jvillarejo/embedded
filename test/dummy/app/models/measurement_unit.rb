class MeasurementUnit
  attr_reader :magnitude, :quantity

  def initialize(values)
    @magnitude = values.fetch(:magnitude)
    @quantity = values.fetch(:quantity)
  end

  def ==(other)
    return false if !other.is_a?(MeasurementUnit)

    # Simplified, in real life it would need to manage conversions to check if are equals
    # 100lb = 45.3592kg
    magnitude == other.magnitude && quantity == other.quantity
  end
end
