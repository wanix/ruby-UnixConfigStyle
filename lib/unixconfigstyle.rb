###############################################################################
## Author: Erwan SEITE
## Aim: Read or Write config files written in Unix Style
## Licence : GPL v2
## Source : https://github.com/wanix/ruby-UnixConfigStyle
## The section name "[-UnixConfigStyle-]" is reserved for the global one
###############################################################################
class UnixConfigStyle

  Version = '1.0'

  @@rootsection="[-UnixConfigStyle-]"

  @@regexpStruct={}
  #Empty line definition
  @@regexpStruct[:emptyline] = /^\s*$/
  #Comment line definition
  @@regexpStruct[:commentline] = /^\s*[#;]/
  #Section Line definition
  @@regexpStruct[:sectionline] = /^\s*\[(.+?)\]\s*([#;].*)?$/
  #Parameter line definition
  @@regexpStruct[:paramline] = /^\s*([\d\w-_]+)\s*=.*$/
  @@regexpStruct[:paramlinequote] = /^\s*([\d\w-_]+)\s*=\s*('.*')\s*([#;].*)?$/
  @@regexpStruct[:paramline2quote] = /^\s*([\d\w-_]+)\s*=\s*(".*")\s*([#;].*)?$/
  @@regexpStruct[:paramlinenormal] = /^\s*([\d\w-_]+)\s*=\s*(.*?)\s*([#;].*)?$/

  # (private) Initialise the class and read the file
  def initialize(config_file=nil)
    @sections = {}

    if(config_file)
      push_unix_config_file(config_file)
    end
  end
  private :initialize

  # (private) Validate a file is readable
  def validate(fileToRead)
    unless File.readable?(fileToRead)
      raise Errno::EACCES, "Can't read #{fileToRead}"
    end
  end
  private :validate

  # read a config file and add its properties to the end of the object ones
  def push_unix_config_file(config_file)
    add_unix_config_file(config_file,"push")
  end

  # read a config file and add its properties to the start of the object ones
  def insert_unix_config_file(config_file)
    add_unix_config_file(config_file,"insert")
  end

  # (private) read a config file and add its properties to the current object
  def add_unix_config_file(config_file, operation="push")
    if operation != "push" and operation != "insert"
      raise ArgumentError, "operation #{operation} not allowed", caller
    end
    validate(config_file)

    file = File.open(config_file, 'r')

    @sections[@@rootsection]={} unless @sections.key?(@@rootsection)
    currentSection=@@rootsection

    while !file.eof?
      line = file.readline
      #We ignore the empty lines
      next if @@regexpStruct[:emptyline].match(line)
      #We ignore the comment lines
      next if @@regexpStruct[:commentline].match(line)
      #Change the current section if a new line section is matched
      sectionmatch = @@regexpStruct[:sectionline].match(line)
      if sectionmatch
        currentSection=sectionmatch[1]
        #If this section is seen for the first time, initialise the hash
        @sections[currentSection]={} unless @sections.key?(currentSection)
        next
      end
      #Now we have to recognize the line or there is an error in the file ... or a bug here :)
      paramlinematch = @@regexpStruct[:paramline].match(line)
      if paramlinematch
        #First time this param is seen ?
        @sections[currentSection][paramlinematch[1]]=[] unless @sections[currentSection].key?(paramlinematch[1])
        parammatch = @@regexpStruct[:paramlinequote].match(line)
        if parammatch
          if operation == "push"
            @sections[currentSection][paramlinematch[1]].push(parammatch[2])
          elsif operation == "insert"
            @sections[currentSection][paramlinematch[1]].insert(1,parammatch[2])
          end
          next
        end
        parammatch = @@regexpStruct[:paramline2quote].match(line)
        if parammatch
          if operation == "push"
            @sections[currentSection][paramlinematch[1]].push(parammatch[2])
          elsif operation == "insert"
            @sections[currentSection][paramlinematch[1]].insert(1,parammatch[2])
          end
          next
        end
        parammatch = @@regexpStruct[:paramlinenormal].match(line)
        if parammatch
          if operation == "push"
            @sections[currentSection][paramlinematch[1]].push(parammatch[2])
          elsif operation == "insert"
            @sections[currentSection][paramlinematch[1]].insert(1,parammatch[2])
          end
          next
        end
      else
        warn("[warning] unrecognized line "+file.lineno.to_s+" in "+@unix_config_file+" : "+line)
      end
    end
  end
  private :add_unix_config_file

  # For debugging purpose : print the object in a unix config style
  def print(comment=nil)
    if comment
      puts "##{comment}"
    end
    if @sections.key?(@@rootsection)
      @sections[@@rootsection].keys.each do |param_key|
        @sections[@@rootsection][param_key].each do |param_value|
          puts "#{param_key}=#{param_value}"
        end
      end
    end
    @sections.keys.each do |section_key|
      if section_key == @@rootsection
        next
      end
      puts "[#{section_key}]"
      @sections[section_key].keys.each do |param_key|
        @sections[section_key][param_key].each do |param_value|
          puts "#{param_key}=#{param_value}"
        end
      end
    end
  end #def puts

  #Get a param array
  def getParams (key, section=@@rootsection)
    if @sections.key?(section)
      if @sections[section].key?(key)
        return @sections[section][key]
      end
    end
    return nil
  end

  #Get the first param for a key (config first win)
  def getFirstParam (key, section=@@rootsection)
    if @sections.key?(section)
      if @sections[section].key?(key)
        return @sections[section][key].first
      end
    end
    return nil
  end

  #Get the last param for a key (config last win)
  def getLastParam (key, section=@@rootsection)
    if @sections.key?(section)
      if @sections[section].key?(key)
        return @sections[section][key].last
      end
    end
    return nil
  end

end
