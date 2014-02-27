# Activerecord::PgArray

This gem defines methods in your models for ActiveRecord attributes that use Postgres's arrays.

I wrote this gem because I realized that working with Postgresql arrays was not as straight-forward as I had hoped.

## Installation

Add this line to your application's Gemfile:

    gem 'activerecord-pg_array'

## Usage

Then in your classes that inherit from ActiveRecord `include ActiveRecord::PGArray`

### Example:

Given the following migration:

    class CreateMyModel < ActiveRecord::Migration
      def change
        create_table :my_models do |t|
          t.string :name
          t.integer :friend_ids, array: true, default: []
        end
    
        add_index :my_models, :friend_ids, using: 'gin'
      end
    end

And class:

    class MyClass < ActiveRecord::Base
      include ActiveRecord::PGArray
    end

The following methods are automatically defined for "friend_ids":

* add_friend(object)
* add_friend!(object)
* add_friends(objects)
* remove_friend(object)
* remove_friend!(object)

## Roadmap

* TESTS! Yes I plan on writing tests for this. This gem was pulled out of a rails project and that is where my tests for this are right now. When I have an opportunity, I will add tests.
* Atomic operations

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
