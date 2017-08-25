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
