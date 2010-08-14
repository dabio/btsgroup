require 'bts'

dbconfig = YAML.load(File.read('config/database.yml'))
BTS::Models::Base.establish_connection dbconfig['production']

run BTS