# encoding: utf-8

require 'sinatra'
require "sinatra/cookies"

require 'json'
require 'awesome_print'
require "google/api_client"
require "google_drive"
require 'redis'
require 'sidekiq'

configure :production do
    require 'newrelic_rpm'
    uri = URI.parse(ENV["REDISCLOUD_URL"])
    $redis = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
end
Dir.glob('./{models,helpers,controllers,workers}/*.rb').each { |file| require file }

set :bind, '0.0.0.0'

module WebhookConnector
  class GoogleSheets < Sinatra::Base
  	  helpers Sinatra::Cookies
      post "/google-sheets/rows/create/*:*:*" do |label, spreadsheet_title, worksheet_title|
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
end