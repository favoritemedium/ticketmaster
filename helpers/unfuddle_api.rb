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

    def initialize(username=nil, password=nil, projectid=0, milestoneid=nil)
      @username = username
      @password = password
      @projectid = projectid
      @milestoneid = milestoneid
    end

    def xmlescape(text)
      text.gsub('&','&amp;').gsub('<','&lt;').gsub('>','&gt;').gsub('"','&quot;')
    end

    def submit(summary='', description='')
      @summary = summary
      @description = description
      magic = HTTPClient.new
      magic.set_auth('https://favmed.unfuddle.com/', @username, @password)
      r = magic.post(
        "https://favmed.unfuddle.com/api/v1/projects/#{@projectid}/tickets",
        "<ticket><summary>#{xmlescape(@summary)}</summary><description>#{xmlescape(@description)}</description><milestone-id type=\"integer\">#{@milestoneid}</milestone-id><priority>3</priority></ticket>",
        { 'Accept' => 'application/json', 'Content-Type' => 'application/xml' }
      )
      puts r.inspect
      case r.status
        when 401 then raise Authentication
        when 201 then [true, "Ticket created."]
        when 400 then [false, "Error(s): "+JSON::parse(r.content).join('; ')]
      else
        [false, "Error "+r.status.to_s]
      end
    end

  end

end
