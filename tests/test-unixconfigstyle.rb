#!/usr/bin/ruby
###############################################################################
## Author: Erwan SEITE
## Aim: Read or Write config files written in Unix Style
## Licence : GPL v2
## Source : https://github.com/wanix/ruby-UnixConfigStyle
## Help : http://betterspecs.org/fr/
###############################################################################
require 'rspec'
require '../lib/unixconfigstyle.rb'

describe 'ruby-UnixConfigStyle' do

  unix_config_file1='./configfiles/conf_unix1.cfg'
  context "The file #{unix_config_file1} should be parsed" do
    it "Should create an unixconfigstyle object" do
      objUnixConfFile1 = UnixConfigStyle.new(unix_config_file1)
    end
  end
end
