require 'optparse'
require 'io/console'
require './helpers/unfuddle_api'

# newticket.rb - submit a ticket to Favorite Medium's Unfuddle (command line)
#
# For a list of options, do:  ruby newticket.rb -h

opt = {}
OptionParser.new do |o|
  o.banner = "Usage: ruby newticket.rb [options]"
  o.on("-u", "--username [USERNAME]", "Unfuddle username") { |a| opt[:username] = a }
  o.on("--password [PASSWORD]", "Unfuddle password") { |a| opt[:password] = a }
  o.on("-p", "--projectid [PROJECTID]", "Project ID (number)") { |a| opt[:projectid] = a.to_i }
  o.on("-s", "--summary [SUMMARY]", "Ticket summary") { |a| opt[:summary] = a }
  o.on("-d", "--description [DESCRIPTION]", "Ticket description") { |a| opt[:description] = a }
  o.on("-q", "--quiet", "Suppress output") { opt[:quiet] = true }
end.parse!

if !opt.has_key?(:username)
  STDOUT.print "Unfuddle username: "
  opt[:username] = STDIN.gets.chomp
end

if !opt.has_key?(:password)
  STDOUT.print "Unfuddle password: "
  opt[:password] = STDIN.noecho(&:gets).chomp
  STDOUT.print "\n"
end

# only prompt for the project ID if we're also prompting for the summary and/or description
project_id = 313388; # default to nexant
if !opt.has_key?(:projectid) && !(opt.has_key?(:summary) && opt.has_key?(:description))
  STDOUT.print "Project ID (#{project_id}): "
  x = STDIN.gets.chomp
  project_id = x.to_i if x.match(/^\d+$/)
end
opt[:projectid] = project_id

if !opt.has_key?(:summary)
  STDOUT.print "Ticket summary: "
  opt[:summary] = STDIN.gets.chomp
end

if !opt.has_key?(:description)
  STDOUT.print "Ticket description: "
  opt[:description] = STDIN.gets.chomp
end


#go

begin
  fu = UnfuddleApi::Futicket.new(opt[:username], opt[:password], opt[:projectid])
  ok, message = fu.submit(opt[:summary], opt[:description])
rescue UnfuddleApi::Authentication
  ok = false
  message = "Authentication error."
end
puts message if !opt.has_key?(:quiet)
exit ok
