require "sinatra/base"
require "yaml"
require "./helpers/unfuddle_api.rb"
require "./helpers/utest_aids.rb"

# ticketmaster requires the following environment variables to be set:
# TM_USER
# TM_PASS - credetionals to access ticketmaster
# UNFUDDLE_USER
# UNFUDDLE_PASS - credentials to access unfuddle.
# UNFUDDLE_PROJECT_ID - unfuddle project ID, e.g. 313388

class String
  def safe
    Rack::Utils.escape_html self
  end
end

class Ticketmaster < Sinatra::Base

  class << self
    attr_accessor :config
  end

  use Rack::Session::Pool

  self.config = YAML::load(File.open("./config/credentials.yaml")) rescue {}

  use Rack::Auth::Basic, "Restricted Area" do |user, pass|
    [user, pass] == [
      Ticketmaster.config["TM_USER"] || ENV["TM_USER"],
      Ticketmaster.config["TM_PASS"] || ENV["TM_PASS"]
    ]
  end

  get "/" do
    erb :index
  end

  post "/upyougo" do
    session[:tickets] = UtestAids::ParseCsv.fromfile params[:tickets][:tempfile]
    session[:notice] = "#{session[:tickets].count} tickets uploaded."
    redirect "/verify"
  end

  get "/verify" do
    @tickets = session[:tickets] || []
    redirect "/" if @tickets.empty?
    erb :verify
  end

  post "/awayyougo" do
   tickets = session[:tickets]
    if tickets.empty?
      session[:notice] = "No tickets."
      redirect "/"
    end
    user = params[:user]
    pass = params[:resu]
    if user.empty? || pass.empty?
      session[:notice] = "Please enter a username and password for Unfuddle."
      redirect "/verify"
    end
    submitted = 0
    failed = []
    errors = []
    fu = UnfuddleApi::Futicket.new(user, pass, 313388)
    begin
      tickets.each do |t|
        ok, message = fu.submit(t[:title], t[:description])
        if ok
          submitted += 1
        else
          failed << t
          errors << message
        end
      end
    rescue UnfuddleApi::Authentication
      failed += tickets[(submitted+failed.count)..-1]
      errors << "Authentication error."
    end
    errors.uniq!
    session[:notice] = "#{submitted} ticket(s) submitted."
    redirect "/" if failed.empty?
    session[:errors] = errors.join(", ")
    session[:tickets] = failed
    redirect "/verify"
  end

end

