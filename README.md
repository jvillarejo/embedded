# Embedded

Embedded is a small rails engine to correctly persist Value Objects in Active Record Object columns

## Code Status
[![Build Status](https://travis-ci.org/jvillarejo/embedded.svg?branch=master)](https://travis-ci.org/jvillarejo/embedded)

Embedded supports and was tested against this Ruby and Rails versions:

* Ruby 2.1.5 and Rails 3.2 (it's a shame but I have a legacy project)
* Ruby 2.4 and Rails 4.2
* Ruby 2.4 and Rails 5.1
* Ruby 2.4 and Rails 5.2
* Ruby 2.5 and Rails 4.2
* Ruby 2.5 and Rails 5.1
* Ruby 2.5 and Rails 5.2

## Motivation

There are objects in every domain that don't have an identity by themselves but in which their equality depends on the values of their attributes.

Example: prices, any magnitude, a color, a polygon.

Defining a value object lets you extract common behavior from your current bloated active record objects.

Every time I did this, I had to define a getter and a setter for the value object, and map those to the columns of the object that gets persisted, so I thought that it would be better to define those value object attributes in a declarative way and let the plugin do the magic behind.

For more info about value objects check this links:

* [Value Object by Martin Fowler](https://martinfowler.com/bliki/ValueObject.html)
* [Don't forget about Value Objects](https://plainoldobjects.com/2017/03/19/dont-forget-about-value-objects)

### What about ActiveRecord composed_of API ?

Sincerly at the time of written this I didn't know about ActiveRecord [composed_of](http://api.rubyonrails.org/classes/ActiveRecord/Aggregations/ClassMethods.html) API. 

I feel embarrassed about this because I usually read the Rails code, maybe my mind forgot about it. Thanks to a very good samaritan on Reddit that pointed me to it. 

As I take a very good look to composed_of there are some things that make me noise: 
* A lack of conventions, you have to configure everything in it.
* The mapping is defined as an array of arrays instead of a simple hash as embedded. 
* That Rails dev team tried remove and then reverted it. [PR 6743](https://github.com/rails/rails/pull/6743)

So I'm thinking to still use and maintain this gem, but I will improve it to use composed_of under the hood as it's not a good practice to duplicate functionalities in a system. And if the Rails dev team remove the composed_of API in a future, I can maintain it with this gem too. 

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

Let's say you have a Reservation in your active record model and that it has a start_time and an end_time. And that you want to calculate the duration in hours of the period.

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

Now you are starting to see the problem. That behavior belongs to a TimeInterval object that has a start_time an end_time and let's you calculate all the durations and intervals you want.

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
Also you can persist the reservation, and when fetching it back from the db its scheduled_time will be a TimeInterval

```ruby
  t = TimeInterval.new(start_time: Time.now, end_time: 3.hours.ago)
  reservation = Reservation.create(scheduled_time: t)

  reservation.reload

  reservation.scheduled_time.hours
  # => 3
```

Embedded also supports passing a hash to the setter, so you can still use ```fields_for``` in form views and also use request params to create activerecord model objects.

```ruby
  reservation = Reservation.create(scheduled_time: {
    start_time: Time.now,
    end_time: 3.hours.ago
  })

  reservation.reload

  reservation.scheduled_time.hours
  # => 3
```

### Database Mapping

The default convention column mapping is the value object name as prefix and the value object attribute as suffix.

Example:
If Reservation attribute name is scheduled_time and its TimeInterval has start_time and end_time attributes, your column names should be defined as followed:

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

Shop attribute name is available time, and its TimeInterval has start_time and end_time attributes. Your column names here must be like this:

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

We can override this convetion if you pass attrs argument as hash where you define the mapping. 

Example: 
```ruby
class PersonalDocument
  attr_reader :number, :type

  def initialize(values = {})
    @number = values.fetch(:number)
    @type = values.fetch(:type)
  end

  def ==(other)
    return false if !other.is_a?(PersonalDocument)

    @number == other.number && @type == other.type
  end
end

class Person < ApplicationRecord
  embeds :identification, attrs: { 
    number: :id_number, 
    type: :id_type
  }, class_name: 'PersonalDocument'
end

class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :id_number
      t.string :id_type

      t.timestamps
    end

    add_index :people, :id_number
    add_index :people, :id_type
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

And if we want to check the orders for a specific price we can do it like this:

```ruby
price = Price.new(currency: 'BTC', amount: BigDecimal.new('2.5'))
gambles = BuyOrder.embedded.where(price: price).to_a

# => [#<Order id: 1, price_currency: "BTC", price_amount: #<BigDecimal:555e61776630,'0.25E1',18(36)>, created_at: "2017-03-17 17:11:00", updated_at: "2017-10-18 17:11:00">]
```

In order to search with value objects you should use embedded method. This decision was made because I didn't want to monkey patch the activerecord method 'where'.

This way the embedded method returns another scope in which the method 'where' is overridden. If you want to query by the column attributes you can still use the default 'where' method. 

```ruby
jpm_orders = BuyOrder.where(price_currency: 'BTC')
jpm_orders.find_each {|o| o.trader.fire! }
``` 

## Contributing

Everyone is encouraged to help to improve this project. Here are a few ways you can help:

- [Report bugs](https://github.com/jvillarejo/embedded/issues)
- Fix bugs and [submit pull requests](https://github.com/jvillarejo/embedded/pulls)
- Suggest or add new features

## Maintainer

Juani Villarejo <contact@jonvillage.com>

## License
The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
