#
#   this is btsgroup.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

Encoding.default_external = 'UTF-8'

require './application'

use Hassle
run Sinatra::Application
