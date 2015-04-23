require 'rspec'
require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end
require 'domkey'
SimpleCov.command_name "test:units"

module DomkeySpecHelper

  def goto_html file
    goto("file://" + __dir__ + "/html/#{file}")
  end

  def goto path
    Domkey.browser.goto path
  end

end


class LocalChromeBrowser < Domkey::Browser::Factory
  def factory
    Watir::Browser.new :chrome
  end
end

class DockerStandAloneDebug < Domkey::Browser::Factory

  def factory
    # Mac OS X with boot2docker
    # docker run -d -p 5905:5900 -p 4444:4444 -v `pwd`:`pwd` -w `pwd` --name domkey_chrome rubytester/standalone-chrome-debug:41
    # open vnc://:secret@$(boot2docker ip):5905
    # http://$(boot2docker ip):4444/wd/hub
    Watir::Browser.new :chrome, url: "http://192.168.59.103:4444/wd/hub"
  end
end

#Domkey::Browser.factory = DockerStandAloneDebug.new
Domkey::Browser.factory = LocalChromeBrowser.new

RSpec.configure do |config|
  config.include DomkeySpecHelper
  config.after(:suite) do
    Domkey.browser.quit
  end
end