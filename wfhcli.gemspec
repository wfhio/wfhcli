Gem::Specification.new do |s|
  s.name        = 'wfhcli'
  s.version     = '0.3.1'
  s.date        = '2015-01-04'
  s.summary     = 'WFH.io CLI tool'
  s.description = "CLI tool to query WFH.io's JSON API"
  s.authors     = ['Matt Thompson']
  s.email       = 'admin@wfh.io'
  s.files       = ['README.md', 'lib/wfhcli.rb']
  s.executables << 'wfhcli'
  s.homepage    = 'https://github.com/wfhio/wfhcli'
  s.license     = 'MIT'
  s.add_runtime_dependency 'rest-client'
  s.add_runtime_dependency 'thor'
end
