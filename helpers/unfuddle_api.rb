require 'httpclient'
require 'json'

# Submit a ticket to Favorite Medium's Unfuddle.
#
# Method Futicket.submit returns:
#   boolean true (success) or false (failure)
#   string message
#
# Raises UnfuddleApi::Authentication if username/password combination
# is not valid.

module UnfuddleApi

  class Authentication < StandardError
  end

  class Futicket

    def initialize(username=nil, password=nil, projectid=0)
      @username = username
      @password = password
      @projectid = projectid
    end

    def submit(summary='', description='')
      @summary = summary
      @description = description
      magic = HTTPClient.new
      magic.set_auth('https://favmed.unfuddle.com/', @username, @password)
      r = magic.post(
        "https://favmed.unfuddle.com/api/v1/projects/#{@projectid}/tickets",
        "<ticket><summary>#{@summary}</summary><description>#{@description}</description><priority>3</priority></ticket>",
        { 'Accept' => 'application/json', 'Content-Type' => 'application/xml' }
      )
      puts r.inspect
      case r.status
        when 401 then raise Authentication
        when 201 then [true, "Ticket created."]
        when 400 then [false, "Error(s): "+JSON::parse(r.content).join('; ')]
      else
        [false, "Error "+r.status]
      end
    end

  end

end
