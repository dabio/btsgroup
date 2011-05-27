# encoding: utf-8
#
#   this is btsgroup.de, a sinatra application
#   it is copyright (c) 2009-2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

module DataMapper
  class Property

    autoload :BCryptHash, root_path('models/dm/bcrypt_hash')
    autoload :Enum, root_path('models/dm/enum.rb')

    module Flags
      def self.included(base)
        base.class_eval <<-RUBY, __FILE__, __LINE__ + 1
          extend DataMapper::Property::Flags::ClassMethods

          accept_options :flags
          attr_reader :flag_map

          class << self
            attr_accessor :generated_classes
          end

          self.generated_classes = {}
        RUBY
      end

      def custom?
        true
      end

      module ClassMethods
        # TODO: document
        # @api public
        def [](*values)
          if klass = generated_classes[values.flatten]
            klass
          else
            klass = ::Class.new(self)
            klass.flags(values)

            generated_classes[values.flatten] = klass

            klass
          end
        end
      end
    end

  end
end

