require 'test_helper'

class Embedded::Test < ActiveSupport::TestCase

  def test_embedded_column_names
    hash = Reservation.embedded_column_names(:time_interval, [:start_time, :end_time])

    assert_equal({
      time_interval_start_time: :start_time,
      time_interval_end_time: :end_time
    }, hash)
  end

  def test_reservation_has_time_interval_getter
    reservation = Reservation.new

    assert reservation.respond_to?(:time_interval)
  end

  def test_reservation_return_time_interval
    reservation = Reservation.new
    time_interval = TimeInterval.new(start_time: 3.hours.ago, end_time: Time.zone.now)
    reservation.time_interval = time_interval

    assert_equal time_interval, reservation.time_interval
  end

  def test_reservation_return_time_interval_after_save
    reservation = Reservation.new
    time_interval = TimeInterval.new(start_time: 3.hours.ago, end_time: Time.zone.now)
    reservation.time_interval = time_interval
    reservation.save
    reservation.reload

    assert_equal time_interval, reservation.time_interval
  end

  def test_reservation_with_time_interval_on_constructor
    time_interval = TimeInterval.new(start_time: 3.hours.ago, end_time: Time.zone.now)
    reservation = Reservation.new(time_interval: time_interval)
    assert_equal time_interval, reservation.time_interval
  end

  def test_reservation_return_persisted_when_querying_with_time_interval
    time_interval_1 = TimeInterval.new(start_time: 3.hours.ago, end_time: Time.zone.now)
    reservation_1 = Reservation.create(time_interval: time_interval_1)
    
    time_interval_2 = TimeInterval.new(start_time: 4.hours.ago, end_time: 2.hours.ago)
    reservation_2 = Reservation.create(time_interval: time_interval_2)

    assert_equal reservation_2, Reservation.embedded
                                           .where(time_interval: time_interval_2)
                                           .first
  end

  def test_order_return_persisted_when_querying_with_price
    price_1 = Price.new(currency: 'ARS', amount: 350)
    order_1 = Order.create(price: price_1)

    price_2 = Price.new(currency: 'USD', amount: 100)
    order_2 = Order.create(price: price_2)

    assert_equal order_2, Order.embedded
                               .where(price: price_2)
                               .first
  end

  def test_order_return_persisted_when_querying_with_id
    price_1 = Price.new(currency: 'ARS', amount: 350)
    order_1 = Order.create(price: price_1)

    price_2 = Price.new(currency: 'USD', amount: 100)
    order_2 = Order.create(price: price_2)

    assert_equal order_2, Order.where(id: order_2.id)
                               .first
  end

  def test_reservation_has_time_interval_setter
    reservation = Reservation.new

    assert reservation.respond_to?(:time_interval=)
  end
end
