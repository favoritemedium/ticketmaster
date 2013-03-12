require 'optparse'
require './helpers/utest_aids'

# csv2tickets.rb - parse a utest-format csv file and make human-readable tickets
#
# Usage: ruby csv2tickets.rb csvfile


if ARGV.length != 1 || ARGV[0][0] == ("-")
  puts "Usage: ruby csv2tickets.rb csvfile"
  exit 1
end

fn = ARGV[0]
if !File.exist?(fn)
  puts "csv2tickets: Cannot open `#{fn}': No such file"
  exit 1
end

if File.directory?(fn)
  puts "csv2tickets: #{fn} is a directory."
  exit 1
end

tickets = UtestAids::ParseCsv.fromfile fn

tickets.each do |t|
 puts
 puts "#"*(t[:title].length+4)
 puts "# "+t[:title]+" #"
 puts "#"*(t[:title].length+4)
 puts
 puts t[:description]
end
