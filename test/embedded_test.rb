require 'test_helper'

class Embedded::Test < Minitest::Test

  def setup
  end

  def teardown
    Reservation.destroy_all
    Order.destroy_all
  end

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
    time_interval = TimeInterval.new(start_time: 3.hours.ago, end_time: Time.now)
    reservation.time_interval = time_interval

    assert_equal time_interval, reservation.time_interval
  end

  def test_reservation_return_time_interval_after_save
    reservation = Reservation.new
    time_interval = TimeInterval.new(start_time: 3.hours.ago, end_time: Time.now)
    reservation.time_interval = time_interval
    reservation.save
    reservation.reload

    assert_equal time_interval, reservation.time_interval
  end

  def test_reservation_with_time_interval_on_constructor
    time_interval = TimeInterval.new(start_time: 3.hours.ago, end_time: Time.now)
    reservation = Reservation.new(time_interval: time_interval)
    assert_equal time_interval, reservation.time_interval
  end

  def test_order_has_class_name_and_attr
    weight = MeasurementUnit.new(magnitude: 'kg', quantity: 100)

    order = Order.new(weight: weight)
    order.save
    order.reload

    assert_equal weight, order.weight
  end

  def test_reservation_return_persisted_when_querying_with_time_interval
    time_interval_1 = TimeInterval.new(start_time: 3.hours.ago, end_time: Time.now)
    Reservation.create(time_interval: time_interval_1)

    time_interval_2 = TimeInterval.new(start_time: 4.hours.ago, end_time: 2.hours.ago)
    reservation_2 = Reservation.create(time_interval: time_interval_2)

    assert_equal reservation_2, Reservation.embedded
                                           .where(time_interval: time_interval_2)
                                           .first
  end

  def test_embedded_doestn_overrides_embedded_atrributes_when_querying
    time_interval_1 = TimeInterval.new(start_time: 3.hours.ago, end_time: Time.now)
    Reservation.create(time_interval: time_interval_1)

    time_interval_2 = TimeInterval.new(start_time: 4.hours.ago, end_time: 2.hours.ago)
    Reservation.create(time_interval: time_interval_2)

    assert_equal 0, Reservation.where(time_interval_start_time: time_interval_1.start_time)
                                           .embedded
                                           .where(time_interval: time_interval_2)
                                           .size
  end

  def test_embedded_querying_class_scope
    assert_equal Embedded::Scope, Reservation.embedded.class
  end

  def test_embedded_querying_class_scope_chained
    assert_equal Embedded::Scope, Reservation.embedded
                                             .where.class
  end

  def test_embedded_querying_class_scope_withoud_embedded
    assert_equal ActiveRecord::QueryMethods::WhereChain, Reservation.where.class
  end

  def test_embedded_doesnt_override_non_embedded_atrributes_when_querying
    time_interval_1 = TimeInterval.new(start_time: 3.hours.ago, end_time: Time.now)
    reservation_1 = Reservation.create(time_interval: time_interval_1)

    time_interval_2 = TimeInterval.new(start_time: 4.hours.ago, end_time: 2.hours.ago)
    Reservation.create(time_interval: time_interval_2)

    assert_equal 0, Reservation.where(id: reservation_1.id)
                               .embedded
                               .where(time_interval: time_interval_2)
                               .size
  end

  def test_order_return_persisted_when_querying_with_price
    price_1 = Price.new(currency: 'ARS', amount: 350)
    Order.create(price: price_1)

    price_2 = Price.new(currency: 'USD', amount: 100)
    order_2 = Order.create(price: price_2)

    assert_equal order_2, Order.embedded
                               .where(price: price_2)
                               .first
  end

  def test_order_return_persisted_when_querying_with_multiple_embedded_values
    price_1 = Price.new(currency: 'ARS', amount: 350)
    weight_1 = MeasurementUnit.new(magnitude: 'kg', quantity: 100)
    Order.create(price: price_1,weight: weight_1)

    price_2 = Price.new(currency: 'USD', amount: 100)
    weight_2 = MeasurementUnit.new(magnitude: 'lb', quantity: 100)
    Order.create(price: price_2,weight: weight_2)

    assert_equal 0, Order.embedded
                         .where(price: price_2, weight: weight_1)
                         .size
  end

  def test_order_return_persisted_when_querying_with_chained_embedded_values
    price_1 = Price.new(currency: 'ARS', amount: 350)
    weight_1 = MeasurementUnit.new(magnitude: 'kg', quantity: 100)
    Order.create(price: price_1,weight: weight_1)

    price_2 = Price.new(currency: 'USD', amount: 100)
    weight_2 = MeasurementUnit.new(magnitude: 'lb', quantity: 100)
    Order.create(price: price_2,weight: weight_2)

    assert_equal 0, Order.embedded
                         .where(price: price_2)
                         .where(weight: weight_1)
                         .size
  end

  def test_order_return_persisted_when_querying_with_id
    price_1 = Price.new(currency: 'ARS', amount: 350)
    Order.create(price: price_1)

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
