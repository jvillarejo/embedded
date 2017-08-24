class TimeInterval
  attr_reader :start_time, :end_time

  def initialize(values={})
    @start_time = values.fetch(:start_time)
    @end_time = values.fetch(:end_time)
  end

  def ==(other)
    return false if other.nil?

    @start_time == other.start_time && @end_time == other.end_time
  end
end
