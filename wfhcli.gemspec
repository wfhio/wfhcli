Gem::Specification.new do |s|
  s.name        = 'wfhcli'
  s.version     = '0.5.0'
  s.date        = '2015-10-06'
  s.summary     = 'A CLI wrapper around the WFH.io (https://www.wfh.io) remote job board'
  s.description = s.summary
  s.authors     = ['Matt Thompson']
  s.email       = 'admin@wfh.io'
  s.files       = ['README.md', 'lib/wfhcli.rb']
  s.executables << 'wfhcli'
  s.homepage    = 'https://github.com/wfhio/wfhcli'
  s.license     = 'MIT'
  s.add_runtime_dependency 'rest-client', '~> 1.7.2'
  s.add_runtime_dependency 'thor', '~> 0.19.1'
  s.add_development_dependency 'webmock', '~> 1.11.0'
end
