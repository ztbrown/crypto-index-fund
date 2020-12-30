APP_PATH = File.expand_path('../app', __dir__)

# load all models
Dir["#{APP_PATH}/models/*.rb"].each {|file| require file }

# connect to DB
ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.sqlite3')

