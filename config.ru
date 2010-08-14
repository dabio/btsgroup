require 'bts'

use Rack::Static, :urls => ['/css', '/js', '/images', '/favicon.ico'], :root => 'public'
use Rack::CommonLogger

dbconfig = YAML.load(File.read('config/database.yml'))
BTS::Models::Base.establish_connection dbconfig['production']

run BTS