require 'sinatra'
require 'rest-client'
require 'json'

neo4j_db_url = ENV['NEO4J_URL'] || "http://localhost:7474"
neo4j_db_url_noauth = neo4j_db_url.gsub /http:\/\/\w+:\w+@/, "http://"

REPLACE_DB_HOST = /(#{neo4j_db_url})|(#{neo4j_db_url_noauth})/
REST = RestClient::Resource.new neo4j_db_url

get '/' do
  if request.accept.include?("application/json") || request.accept.include?("text/javascript")
    pass_to_neo4j
  else
    send_file File.join(settings.public_folder, 'index.html')
  end
end

get /\/webadmin.*/ do
  pass_to_neo4j
end

get /\/db\/.*/ do
  pass_to_neo4j
end

options /\/db\/.*/ do
  pass_to_neo4j
end

post /\/db\/data\/node\/.*\/traverse\/.*/ do
  pass_to_neo4j
end

post "/db/manage/server/console/" do
  data = JSON.parse request.body.read
  if data["engine"] == "gremlin"
    content_type "application/json"
    ["Security-Constraint: Gremlin is DISABLED", ""].to_json
  else
    pass_to_neo4j data.to_json
  end
end

post "/db/manage/server/jmx/query" do
  pass_to_neo4j
end

def pass_to_neo4j(data=nil)
  request_method = request.request_method
  # puts "#{request_method} #{request.path}"

  request_method = request_method.downcase.to_sym

  if request_method == :get
    response = REST[request.path].get({:accept => request.accept, :content_type => request.content_type})
  else
    data = data || request.body.read
    response = REST[request.path].send(request_method, data, {:accept => request.accept, :content_type => request.content_type})
  end

  content_type response.headers[:content_type]
  if %W(application/json application/x-javascript text/css text/html).include? response.headers[:content_type]
    response.gsub REPLACE_DB_HOST, ""
  else
    response
  end
end
