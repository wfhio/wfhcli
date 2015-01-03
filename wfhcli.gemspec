Gem::Specification.new do |s|
  s.name        = 'wfhcli'
  s.version     = '0.3.0'
  s.date        = '2015-01-03'
  s.summary     = "WFH.io CLI tool"
  s.description = "CLI tool to query WFH.io's JSON API"
  s.authors     = ["Matt Thompson"]
  s.email       = 'admin@wfh.io'
  s.files       = ["lib/wfhcli.rb"]
  s.executables << 'wfhcli'
  s.homepage    = 'https://github.com/wfhio/wfhcli'
  s.license     = 'MIT'
  s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "thor"
end
