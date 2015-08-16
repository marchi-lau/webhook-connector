require './connectors'

Sidekiq::Web.use Rack::Session::Cookie, :secret => "SOMETHING SECRET"
Sidekiq::Web.instance_eval { @middleware.reverse! } # Last added, First Run

run Rack::URLMap.new('/' => WebhookConnector::GoogleSheets, '/sidekiq' => Sidekiq::Web)