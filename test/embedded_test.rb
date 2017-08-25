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

  def test_reservation_has_time_interval_setter
    reservation = Reservation.new

    assert reservation.respond_to?(:time_interval=)
  end
end
