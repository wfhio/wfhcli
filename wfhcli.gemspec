Gem::Specification.new do |s|
  s.name        = 'wfhcli'
  s.version     = '0.0.1'
  s.date        = '2014-10-20'
  s.summary     = "wfhcli"
  s.description = "WFH.io CLI tool"
  s.authors     = ["Matt Thompson"]
  s.email       = 'admin@wfh.io'
  s.files       = ["lib/wfhcli.rb"]
  s.executables << 'wfhcli'
  s.homepage    = 'https://github.com/wfhio/wfhcli'
  s.license     = 'MIT'
  s.add_runtime_dependency "rest-client"
  s.add_runtime_dependency "thor"
end
