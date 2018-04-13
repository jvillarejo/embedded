class TimeInterval
  attr_reader :start_time, :end_time

  def initialize(values={})
    @start_time = values.fetch(:start_time)
    @end_time = values.fetch(:end_time)
  end

  def ==(other)
    return false if other.nil?
    @start_time.utc.round == other.start_time.utc.round && 
    @end_time.utc.round == other.end_time.utc.round
  end
end


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

class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
end

class Order < ApplicationRecord
  extend Embedded::Model

  embeds :price, attrs: [:currency, :amount]
  embeds :weight, attrs: [:magnitude, :quantity], class_name: 'MeasurementUnit'
end

class Reservation < ApplicationRecord
  extend Embedded::Model

  embeds :time_interval, attrs: [:start_time, :end_time]
end