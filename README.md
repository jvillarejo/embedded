# Embedded

Embedded is a small rails engine to correctly persist Value Objects in Active Record Object columns

## Motivation

There objects in every domain that doesn't have an identity by itself but their equality depends on the values of their attributes.

Example: prices, any magnitude, a color, a polygon.

Defining a value objects lets you extract common behavior from your current bloated active record objects.

Every time that I did this I had to define a getter and setter for the value object and map those to the columns of the object that gets persisted, so I thought it would be better to define those value object attributes in a declarative way and let the plugin do the magic behind.

For more info about value objects check this links:

* [Value Object by Martin Fowler](https://martinfowler.com/bliki/ValueObject.html)
* [Don't forget about Value Objects](https://plainoldobjects.com/2017/03/19/dont-forget-about-value-objects)

## Features

It lets you define value objects and map them into the corresponding value object attributes columns

It lets you query by those value objects in a safe way, without monkeypatching the default activerecord classes

## Installation
Add this line to your application's Gemfile:

```ruby
gem 'embedded'
```

Create an initializer in your rails project

```ruby
# config/initializers/embedded_initializer
ActiveRecord::Base.send(:extend, Embedded::Model)
```

Or you can extend the ApplicationRecord class
```ruby
class ApplicationRecord < ActiveRecord::Base
  extend Embedded::Model
  self.abstract_class = true
end
```


## Usage

Let's say you have a Reservation in your active record model and that reservation has a start_time, and end_time. And want you calculate the duration in hours of the period.

```ruby
  class Reservation < ApplicationRecord

    def period_in_hours
      (end_time - start_time).round / 60 / 60
    end
  end
```

```ruby
  reservation = Reservation.new(start_time: Time.now, end_time: 3.hours.ago)
  reservation.period_in_hours
  # => 3
```

 If you want your model to have cohesion, something is not quite right when a reservation is calculating time intervals of a period, but let's keep that for a while.

 You have a new requirement, you need to persist available hours for a shop, and you want to calculate the duration in hours of the available time

 ```ruby
   class Shop < ApplicationRecord
      def opening_period_in_hours
        (open_time - closed_time).round / 60 / 60
      end
   end
 ```

 ```ruby
  shop = Shop.new(start_time: Time.now, end_time: 3.hours.ago)
  shop.period_in_hours
  # => 3
```

Now you are starting to see the problem. That behavior belongs to a TimeInterval object that has start_time and end_time and let's you calculate all durations and intervals you want.

So with embedded in hand we can do this.

We have a reservation that has an attribute scheduled_time of type TimeInterval and will map the start_time and end_time attributes to the ones in TimeInterval

```ruby
class Reservation < ApplicationRecord
  embeds :scheduled_time, attrs: [:start_time, :end_time], class_name: 'TimeInterval'
end
```

The same here with the shop

```ruby
class Shop < ApplicationRecord
  embeds :available_time, attrs: [:start_time, :end_time], class_name: 'TimeInterval'
end
```

TimeInterval is a plain PORO, it just need the attributes that you defined in your activerecord objects mapping.

```ruby
  class TimeInterval
    attr_reader :start_time, :end_time

    def initialize(values)
      @start_time = values.fetch(:start_time)
      @end_time = values.fetch(:end_time)

      # you can validate as you want, here or in a valid? method that you define
    end

    def hours
      minutes / 60
    end

    def minutes
      seconds / 60
    end

    def seconds
      (end_time - start_time).round
    end
  end
```

Now you can pass available time to shop constructor and check the duration directly
 ```ruby
  t = TimeInterval.new(start_time: Time.now, end_time: 3.hours.ago)
  shop = Shop.new(available_time: t)
  shop.available_time.hours
  # => 3
```
Also you can persist the reservation and when fetching it back of the db it will scheduled_time will be a TimeInterval

```ruby
  t = TimeInterval.new(start_time: Time.now, end_time: 3.hours.ago)
  reservation = Reservation.create(scheduled_time: t)

  reservation.reload

  reservation.scheduled_time.hours
  # => 3
```

### Database Mapping

Your table columns have to be named in a specific way so they are mapped correctly, for example:

Reservation attribute name is scheduled_time and as TimeInterval has start_time and end_time your column names must be defined as scheduled_time_start_time and scheduled_time_end_time

```ruby
class CreateReservations < ActiveRecord::Migration
  def change
    create_table :reservations do |t|
      t.timestamp :scheduled_time_start_time
      t.timestamp :scheduled_time_end_time

      t.timestamps
    end
  end
end
```

Shop attribute name is available time and as TimeInterval has start_time and end_time attributes, your column names here must be defined as available_time_start_time and available_time_end_time

```ruby
class CreateShops < ActiveRecord::Migration
  def change
    create_table :shops do |t|
      t.timestamp :available_time_start_time
      t.timestamp :available_time_end_time

      t.timestamps
    end
  end
end
```

### Querying

For example you have now a model that has prices in different currencies. 

```ruby
price = Price.new(currency: 'BTC', amount: BigDecimal.new('2.5'))
my_gamble = BuyOrder.create(price: price, created_at: Time.new(2015,03,17))

bubble_price = Price.new(currency: 'USD', amount: BigDecimal.new('5257'))
my_intelligent_investment = SellOrder.create(price: price, created_at: Time.new(2017,10,18))
```

And we want to check the orders for a specific price we can do this.

```ruby
price = Price.new(currency: 'BTC', amount: BigDecimal.new('2.5'))
gambles = BuyOrder.embedded.where(price: price).to_a

# => [#<Order id: 1, price_currency: "BTC", price_amount: #<BigDecimal:555e61776630,'0.25E1',18(36)>, created_at: "2017-03-17 17:11:00", updated_at: "2017-10-18 17:11:00">]
```

In order to search with values you should specify with embedded method. This decision was made because I didn't want to monkey patch the activerecord method 'where'.

With this way the embedded method returns another scope in which the method 'where' is overridden. If you want to query by the column attributes you can still use the default 'where' method. 

```ruby
jpm_orders = BuyOrder.where(price_currency: 'BTC')
jpm_orders.find_each {|o| o.trader.fire! }
``` 

## Contributing

Everyone is encouraged to help improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/jvillarejo/embedded/issues)
- Fix bugs and [submit pull requests](https://github.com/jvillarejo/embedded/pulls)
- Suggest or add new features

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
