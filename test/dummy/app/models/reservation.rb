class Reservation < ApplicationRecord
  embeds :time_interval, attrs: [:start_time, :end_time]
end
