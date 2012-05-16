require 'yaml'
require 'bundler'

desc "Test all javascript files with jslint"
task :jslint do
  jslint_config = YAML.load_file('config/jslint.yml')
  js_files = Dir.glob(jslint_config['jslint']['paths']) - jslint_config['jslint']['exclude_paths']

  Bundler.setup
  puts "Running JSLint:\n\n"
  errors = 0
  js_files.each do |js|
    print "checking #{js}... "
    output = `jslint #{js}`
    if $? == 0
      puts "OK"
    else
      print "\n"
      print output
      errors += output.scan(/Lint at/).size
    end
  end

  if errors > 0
    puts "Found #{errors} error#{errors > 1 ? 's' : ''}.\nJSLint test failed."
  else
    puts "No JS errors found."
  end

end

task :cruise => ['jslint', 'spec']