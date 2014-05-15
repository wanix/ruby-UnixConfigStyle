#!/usr/bin/env rspec
###############################################################################
## Author: Erwan SEITE
## Aim: Read or Write config files written in Unix Style
## Licence : GPL v2
## Source : https://github.com/wanix/ruby-UnixConfigStyle
## Help : http://betterspecs.org/fr/
###############################################################################
require 'rspec'
$: << File.join(File.dirname(__FILE__), "..", "lib")
require 'unixconfigstyle.rb'

describe 'ruby-UnixConfigStyle' do

  unix_config_file1=File.dirname(__FILE__)+"/configfiles/conf_unix1.cfg"
  context "The file "+unix_config_file1+" should be parsed" do
    it "Should give you an array of sections (Section1, Section2, newsection)" do
      objUnixConfFile1 = UnixConfigStyle.new(unix_config_file1)
      objUnixConfFile1.getSections().should eq(["Section1","Section2","newsection"])
    end
  end
end
