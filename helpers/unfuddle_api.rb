require 'httpclient'
require 'json'

# Submit a ticket to Favorite Medium's Unfuddle.
#
# Method Futicket.submit returns:
#   boolean true (success) or false (failure)
#   string message

module UnfuddleApi

  class Futicket

    attr_accessor :username, :password, :projectid, :summary, :description

    def initialize(username=nil, password=nil, projectid=0, summary='', description='')
      @username = username
      @password = password
      @projectid = projectid
      @summary = summary
      @description = description
    end

    def submit
      magic = HTTPClient.new
      magic.set_auth('https://favmed.unfuddle.com/', @username, @password)
      r = magic.post(
        "https://favmed.unfuddle.com/api/v1/projects/#{@projectid}/tickets",
        "<ticket><summary>#{@summary}</summary><description>#{@description}</description><priority>3</priority></ticket>",
        { 'Accept' => 'application/json', 'Content-Type' => 'application/xml' }
      )
      return [true, "Ticket created."] if r.status == 201
      return [false, "Authentication error."] if r.status == 401
      return [false, "Error(s): "+JSON::parse(r.content).join('; ')] if r.status == 400
      return [false, "Error "+r.status]
    end

  end

end
