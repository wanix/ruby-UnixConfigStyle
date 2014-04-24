###############################################################################
## Author: Erwan SEITE
## Aim: Read or Write config files written in Unix Style
## Licence : GPL v2
## Source : https://github.com/wanix/ruby-UnixConfigStyle
###############################################################################
class UnixConfigStyle

  Version = '1.0'

  attr_accessor :config_file, :parameters, :sections


  #
  # Initialise the class and read the file
  def initialize(unix_config_file=nil)
    @unix_config_file = unix_config_file
    @parameters = {}
    @sections = []

    if(self.unix_config_file)
      self.validate()
      self.get_unix_config_file()
    end
  end

  def validate()
    unless File.readable?(self.unix_config_file)
      raise Errno::EACCES, "Can't read #{self.unix_config_file}"
    end
  end

end
