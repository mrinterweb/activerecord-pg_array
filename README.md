# Activerecord::PGArray

This gem defines methods in your models for ActiveRecord attributes that use Postgres's arrays.

I wrote this gem because I realized that working with Postgresql arrays was not as straight-forward as I had hoped.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activerecord-pg_array'
```

## Usage

Then in your classes that inherit from ActiveRecord `include ActiveRecord::PGArray`

### Silly Example:

Given the following migration:

```ruby
class CreateWoldTracker < ActiveRecord::Migration
  def change
    create_table :wolf_trackers do |t|
      t.string :name
      t.integer :wolf_ids, array: true, default: []
      t.string :pack_names, array: true, default: []
    end

    add_index :wolf_trackers, :wolf_ids, using: 'gin'
  end
end
```

And class:

```ruby
class WolfTracker < ActiveRecord::Base
  include ActiveRecord::PGArray
end
```

The following methods are automatically defined for "friend_ids":

```ruby
add_wolf(1)                # wolf_ids is appended to
add_pack_name('Stark')
add_wolf!(2)               # wolf_ids appended with atomic update
add_pack_name!('Karstark')
add_wolves([3,4])          # add multiple to wolf_ids. Note: irregular plural method name
add_pack_names(['Greyjoy', 'Bolton'])
remove_wolf(2)             # wolf_ids is modified but not saved
remove_pack_name('Greyjoy')
remove_wolf!(3)            # wolf_ids atomic removal
remove_pack_name!('Bolton')
```

## Roadmap

* TESTS! Yes I plan on writing tests for this. This gem was pulled out of a rails project and that is where my tests for this are right now. When I have an opportunity, I will add tests.
* Actual atomic operations :)

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
