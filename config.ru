# encoding: utf-8
#
#   this is btsgroup.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

if defined? Encoding
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end

require './app'
run BTS

