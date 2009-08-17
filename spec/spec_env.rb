
require 'rubygems'
require 'lore'
require 'lore/model'


Lore.logfile = STDOUT
Lore.enable_query_log
Lore.logger.level = Logger::INFO
Lore.add_login_data 'test' => [ 'cuba', 'cuba23' ]
Lore::Context.enter :test

require './fixtures/models'
require './fixtures/blank_models'
require './spec_helpers'
