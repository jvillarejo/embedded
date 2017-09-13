class Reservation < ApplicationRecord
  extend Embedded::Model

  embeds :time_interval, attrs: [:start_time, :end_time]
end
