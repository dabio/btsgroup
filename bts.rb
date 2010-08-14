require 'camping'

Camping.goes :BTS


class << BTS
  def root
    File.dirname(__FILE__)
  end
  
  def config
    @config ||= YAML.load(IO.read(File.join(root, 'config', 'config.yml'))).symbolize_keys
  end
  
  def title
    config[:title]
  end
end


module BTS::Controllers
  class Index
    def get
      # fetch messages
      render :list
    end
  end
end


module BTS::Views
  def layout
    xhtml_strict
    html do
      head do
        title BTS.title
        link :rel => "stylesheet", :href => "/css/styles.css"
      end
      body do
        h1 "Hello"
        self << yield
      end
    end
  end
  
  def list
  end
end