source 'https://rubygems.org'

activerecord_version = ENV["ACTIVE_RECORD_VERSION"] || "default"
activerecord = case activerecord_version
               when "default"
                 ">= 3.2"
               else
                 "~> #{activerecord_version}"
               end

gem "activerecord", activerecord
gemspec