Gem::Specification.new do |s|
  s.version = '0.0.1'

  s.name = 'apache-log-geo'
  s.summary = "An offline GeoIP CLI filter for Apache (common, combined) logs."
  s.description = <<END
It's like grep but with a knowledge about what data an ip
holds. Requires MaxMind's GeoLite2 DB (GeoLite2-City.mmdb) installed.
END
  s.author = 'Alexander Gromnitsky'
  s.email = 'alexander.gromnitsky@gmail.com'
  s.homepage = 'https://github.com/gromnitsky/apache-log-geo'
  s.license = 'MIT'
  s.files = [
    'apache-log-geo',
    'mmdb-lookup',
    'lib.rb',
    'README.md',
  ]

  s.bindir = '.'
  s.executables = ['apache-log-geo', 'mmdb-lookup']

  s.add_runtime_dependency 'mmdb', '~> 0.3.2'

  s.required_ruby_version = '>= 2.3.0'
end
