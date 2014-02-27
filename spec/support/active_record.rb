require 'active_record'

# create a postgresql database:
#   createdb pg_array_test
ActiveRecord::Base.establish_connection adapter: :postgresql, database: 'pg_array_test', username: ENV['PG_DB_USERNAME'], password: ENV['PG_DB_PASSWORD']

load 'schema.rb'

RSpec.configure do |config|
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end
end

