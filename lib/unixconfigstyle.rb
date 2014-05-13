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
  @@regexpStruct[:paramline] = /^\s*([\d\w\-_]+)\s*=.*$/
  @@regexpStruct[:paramlinequote] = /^\s*([\d\w\-_]+)\s*=\s*('.*')\s*([#;].*)?$/
  @@regexpStruct[:paramline2quote] = /^\s*([\d\w\-_]+)\s*=\s*(".*")\s*([#;].*)?$/
  @@regexpStruct[:paramlinenormal] = /^\s*([\d\w\-_]+)\s*=\s*(.*?)\s*([#;].*)?$/

  #(private) Initialise the class and read the file
  #Parameters:
  # config_file: String (path to a readable unix config file) (optionnal)
  def initialize(config_file=nil)
    @sections = {}

    if(config_file)
      push_unix_config_file(config_file)
    end
  end #initialize
  private :initialize

  #(private) Validate a file is readable
  #Parameters:
  # fileToRead: String (path to a readable file)
  def validate(fileToRead)
    unless File.readable?(fileToRead)
      raise Errno::EACCES, "Can't read #{fileToRead}"
    end
  end #validate
  private :validate

  #Read a config file and add its properties to the end of the object ones
  #Parameters:
  # config_file: String (path to a readable unix config file)
  def push_unix_config_file(config_file)
    add_unix_config_file(config_file,"push")
  end #push_unix_config_file

  #Read a config file and add its properties to the start of the object ones
  #Parameters:
  # config_file: String (path to a readable unix config file)
  def insert_unix_config_file(config_file)
    add_unix_config_file(config_file,"insert")
  end #insert_unix_config_file

  #(private) read a config file and add its properties to the current object
  #Parameters:
  # config_file: String (path to a readable unix config file)
  # operation: String [push|insert]
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
            @sections[currentSection][paramlinematch[1]].insert(0,parammatch[2])
          end
          next
        end
        parammatch = @@regexpStruct[:paramline2quote].match(line)
        if parammatch
          if operation == "push"
            @sections[currentSection][paramlinematch[1]].push(parammatch[2])
          elsif operation == "insert"
            @sections[currentSection][paramlinematch[1]].insert(0,parammatch[2])
          end
          next
        end
        parammatch = @@regexpStruct[:paramlinenormal].match(line)
        if parammatch
          if operation == "push"
            @sections[currentSection][paramlinematch[1]].push(parammatch[2])
          elsif operation == "insert"
            @sections[currentSection][paramlinematch[1]].insert(0,parammatch[2])
          end
          next
        end
      else
        warn("[warning] unrecognized line "+file.lineno.to_s+" in "+@unix_config_file+" : "+line)
      end
    end
    file.close()
  end
  private :add_unix_config_file

  #Write the object in a file
  #Parameters:
  # fileToWrite : String, path to a file
  # comment: String (optionnal)
  def write (fileToWrite, comment=nil)
    File.open(fileToWrite,'w') do |file|
      self.print(comment, file)
    end
  end #def write

  #Print the object in a unix config style into an IO obj
  #Parameters:
  # comment: String
  # io_obj : IO (default stdout)
  def print (comment=nil, io_obj=$stdout)
    raise ArgumentError, 'the argument "comment" must be a String' unless (comment.is_a? String or comment == nil)
    raise ArgumentError, 'the argument "io_obj" must be an IO class or an IO inherited class' unless io_obj.is_a? IO
    if comment
      io_obj.puts "##{comment}"
    end
    if @sections.key?(@@rootsection)
      @sections[@@rootsection].keys.each do |param_key|
        @sections[@@rootsection][param_key].each do |param_value|
          io_obj.puts "#{param_key}=#{param_value}"
        end
      end
    end
    @sections.keys.each do |section_key|
      if section_key == @@rootsection
        next
      end
      io_obj.puts "[#{section_key}]"
      @sections[section_key].keys.each do |param_key|
        @sections[section_key][param_key].each do |param_value|
          io_obj.puts "#{param_key}=#{param_value}"
        end
      end
    end
  end #def print

  #Get all avalaibles sections (all but root one)
  #return an array
  def getSections ()
    allsections = @sections.keys
    if allsections
      allsections.delete(@@rootsection)
    end
    return allsections
  end #def getSections

  #Get all avalaibles keys for this section
  #return an array (or nil if no keys found)
  #Parameters:
  # section: String (optionnal)
  def getKeys (section=@@rootsection)
    if @sections.key?(section)
      return @sections[section].keys
    end
    return nil
  end #def getKeys

  #Add values for a key
  #Parameters:
  # values: Array or String
  # key: String
  # section: String (optionnal)
  def addValues (values, key, section=@@rootsection)
    @sections[section]={} unless @sections.key?(section)
    @sections[section][key]=[] unless @sections[section].key?(key)
    if @sections[section][key].push(values)
      return true
    else
      return false
    end
  end #def addValues

  #Insert values for a key
  #Parameters:
  # values: Array or String
  # key: String
  # section: String (optionnal)
  def insertValues (values, key, section=@@rootsection)
    @sections[section]={} unless @sections.key?(section)
    @sections[section][key]=[] unless @sections[section].key?(key)
    if @sections[section][key].insert(0,values)
      return true
    else
      return false
    end
  end #insertValues

  #Get all values for a key (in a section if given, else in root one)
  #Parameters:
  # key: String
  # section: String (optionnal)
  def getValues (key, section=@@rootsection)
    if @sections.key?(section)
      if @sections[section].key?(key)
        return @sections[section][key]
      end
    end
    return nil
  end #getValues

  #Get the first value for a key (config first win)
  #Parameters:
  # key: String
  # section: String (optionnal)
  def getFirstValue (key, section=@@rootsection)
    if @sections.key?(section)
      if @sections[section].key?(key)
        return @sections[section][key].first
      end
    end
    return nil
  end #getFirstValue

  #Get the last value for a key (config last win)
  #Parameters:
  # key: String
  # section: String (optionnal)
  def getLastValue (key, section=@@rootsection)
    if @sections.key?(section)
      if @sections[section].key?(key)
        return @sections[section][key].last
      end
    end
    return nil
  end #getLastValue

  #Get the value with the given index for a key
  #Parameters:
  # key: String
  # index :Integer (default 0)
  # section: String (optionnal)
  def getValue (key, index=0, section=@@rootsection)
    if @sections.key?(section)
      if @sections[section].key?(key)
        return @sections[section][key][index]
      end
    end
    return nil
  end #getValue

  #Replace the first value by the given one
  #Parameters:
  # newvalue : string
  # key: String
  # section: String (optionnal)
  def replaceFirstValue (newvalue, key, section=@@rootsection)
    if @sections.key?(section)
      if @sections[section].key?(key)
        @sections[section][key].first.replace(newvalue)
      end
    end
    return nil
  end #replaceFirstValue

  #Replace the last value by the given one
  #Parameters:
  # newvalue : string
  # key: String
  # section: String (optionnal)
  def replaceLastValue (newvalue, key, section=@@rootsection)
    if @sections.key?(section)
      if @sections[section].key?(key)
        @sections[section][key].last.replace(newvalue)
      end
    end
    return nil
  end #replaceLastValue

  #Replace the value by the given one
  #Parameters:
  # newvalue : string
  # key: String
  # index :Integer (default 0)
  # section: String (optionnal)
  def replaceValue (newvalue, key, index=0, section=@@rootsection)
    if @sections.key?(section)
      if @sections[section].key?(key)
        @sections[section][key][index].replace(newvalue)
      end
    end
    return nil
  end #replaceValue

  #Replace all the value array by the given one
   #Parameters:
  # newvalues : Array
  # key: String
  # section: String (optionnal)
  def replaceValues (newvalues, key, section=@@rootsection)
    if @sections.key?(section)
      if @sections[section].key?(key)
        @sections[section][key].replace(newvalues)
      end
    end
    return nil
  end #replaceValues

  #Return true if at list one key is present
  def haveKeys? (section=@@rootsection)
    return false if @sections.empty?
    return true unless @sections[section].empty?
    return false
  end #haveKeys?

  #Return true if at list one section is present
  def haveSections? ()
    return true unless self.getSections().empty?
    return false
  end #haveSections?

  #Return true if at list one key is found, whatever its section, global or not
  def isEmpty?()
    return true if self.haveKeys?
    if self.haveSections?
      self.getSections().each do |section|
        return true if self.haveKeys?(section)
      end
    end
    return false
  end #isEmpty?()

end
