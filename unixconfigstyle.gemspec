Gem::Specification.new do |spec|
  spec.name        = 'unixconfigstyle'
  spec.version     = '1.0.0'
  spec.date        = '2014-05-15'
  spec.summary     = "Parse, Write and manage config files in Unix Format"
  spec.description = <<-EOF
  This library manage config file written in Unix style
  Can manage multi-values, concat multiple files, use it as a config object (see easyfpm)
EOF
  spec.authors     = ["Erwan SEITE"]
  spec.email       = 'wanix.fr@gmail.com'
  spec.test_files  = Dir.glob('tests/test-*.rb')
  spec.files       = Dir.glob('lib/*.rb')
  spec.homepage    = 'https://github.com/wanix/ruby-UnixConfigStyle'
  spec.license     = 'GPLv2'
  spec.required_ruby_version = '>= 1.8.7'
end
