# coding:utf-8
#
#   this is btsgroup.de, a cuba application
#   it is copyright (c) 2011 danilo braband (danilo @ berlin,
#   then a dot and a 'de')
#

module Kernel
private
  def coat(file)
    require 'digest/md5'
    Digest::MD5.file("views/#{file}").hexdigest[0..4]
  end

  def root(*args)
    File.join(File.expand_path(File.dirname(__FILE__)), *args)
  end
end

