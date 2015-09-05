require "sinatra"
require "json"

require 'sinatra/cross_origin'

configure do
  enable :cross_origin
end

$received = []

before do
  if request.body.length > 0
    request.body.rewind
    @request_payload = JSON.parse request.body.read
  end
end

options "/" do
  ""
end

post "/" do
  $received << @request_payload
  ""
end

get "/" do
  content_type "application/json"
  JSON.dump($received)
end
