require "sinatra"
require "json"

require 'sinatra/cross_origin'
require 'erb'
require 'ostruct'

configure do
  enable :cross_origin
end


class ErbalT < OpenStruct
  def render(template)
    ERB.new(template).result(binding)
  end
end


$received = Hash.new { |h,k| h[k] = [] }

before do
  if request.body.length > 0
    request.body.rewind
    @request_payload = JSON.parse request.body.read
  end
end

def read_file(file_name)
  File.open(File.join(File.dirname(File.absolute_path(__FILE__)), "files", file_name)).read
end

def render_loader_javascript(user_id)
  ErbalT.new(:user_id => user_id).render(read_file("loader.js.erb"))
end


get "/script_for/:user_id" do |user_id|
  content_type "text/javascript"
  ErbalT.new(:user_id => user_id).render(read_file("scraper.js.erb"))
end

get "/" do
  user_id = params.fetch("user_id", "")
  erb(
    :index,
    :locals => {
      :user_id => params.fetch("user_id", ""), 
      :loader_javascript => "javascript:#{render_loader_javascript(user_id).gsub("\n", "")}"
    }
  )
end

options "/*" do
  ""
end

post "/listens/:user_id" do |user_id|
  $received[user_id] << @request_payload
  ""
end

get "/listens/:user_id" do |user_id|
  content_type "application/json"
  JSON.dump($received[user_id])
end
