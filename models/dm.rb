# encoding: utf-8
#
#   this is btsgroup.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

module DataMapper
  class Property

    autoload :BCryptHash, root_path('models/dm/bcrypt_hash')

  end
end

