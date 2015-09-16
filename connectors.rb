# encoding: utf-8

require 'sinatra'
require "sinatra/cookies"
require 'json'
require 'awesome_print'
require "google/api_client"
require "google_drive"
require 'redis'
require 'sidekiq'
require 'sidekiq/web'
require 'httparty'
Dir.glob('./{models,helpers,controllers,workers}/*.rb').each { |file| require file }
Sidekiq.configure_server do |config|
  config.redis = { url: "redis:#rediscloud:gmXyc9y2Iy2H8u48@pub-redis-11324.us-east-1-3.6.ec2.redislabs.com:11324" }
end
enable :sessions

configure do
    require 'newrelic_rpm'
    # uri = URI.parse(ENV["REDISCLOUD_URL"]) || "redis:#rediscloud:gmXyc9y2Iy2H8u48@pub-redis-11324.us-east-1-3.6.ec2.redislabs.com:11324"
    uri = URI.parse("redis:#rediscloud:gmXyc9y2Iy2H8u48@pub-redis-11324.us-east-1-3.6.ec2.redislabs.com:11324") 
    $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end


set :bind, '0.0.0.0'

module WebhookConnector
  include HTTParty
  default_options.update(verify: false)

  class GoogleSheets < Sinatra::Base
  	  helpers Sinatra::Cookies
      post "/rows/create/*:*:*" do |label, spreadsheet_title, worksheet_title|
            request.body.rewind  # in case someone already read it
            data = request.body.read.force_encoding 'UTF-8'
       client_id = cookies[:client_id]
    client_secret = cookies[:client_secret]
  refresh_token = cookies[:refresh_token]
            # row['abandoned_at_hkt'] = '=TEXT((INDIRECT(ADDRESS(ROW(),COLUMN()+1))*0.001)/(60*60*24)+DATE(1970,1,1)+ TIME(8,0,0),"yyyy/mm/dd hh:mm:ss")'
            GoogleSheetsWorker.perform_async(client_id, client_secret, refresh_token, label, spreadsheet_title, worksheet_title, data)
	return "200"
end
end
 
 class PushNotifier < Sinatra::Base
          helpers Sinatra::Cookies
 post "/" do
    endpoint = cookies[:endpoint]
    keys = []
    params.each do |p|
        keys << {"name" => p[0], "content" => p[1]}
    end
    keys

    payload = {
    "messageRequest": {
        "appId": "com.cathaypacific.IceMobile", #rdns # For SIT/UAT. Production we have 2 app Id
        "global": {},
        "messages": {
            "message": {
                "content": {
                    "priorityService": "false",
                    "data": params[:msgDesc], # Notification Message
                    "mimeType": "text/plain"
                },
                "overrideMessageId": 0, # static
                "startTimestamp": 0, #static
                "expiryTimestamp": 0, #static
                "subscribers": {
                    "subscriber": [{
                       "allActive": "true" # Send to all users, will sent out another sample for specific user later
                          # "ksid": "1679938113096687966" #push_subscription_id
                    }]
                },
                "platformSpecificProps": {
                    "iphone": {
                        "badge": 0,
                        "customData": {
                            "key": keys
                        }
                    },
                    "android": {
                        "key": keys
                    }
                },
                "type": "PUSH" #static
            }
        }
    }
}
    responese = HTTParty.post(endpoint, :body => payload.to_json, :headers => { 'Content-Type' => 'application/json'} , timeout: 180, :verify => false)

    #app_id
    #message
    #landing_page
    #action
    #trip_type
    #origin
    #destination
    #date_departure
    #date_return
    #adult
    #child
    #infant
    #cabin
    #child
    #infant
    return response.body
  end
end
end