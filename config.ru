worker: bundle exec sidekiq -C config/sidekiq.yml

require './connectors'
require 'sidekiq'
require 'sidekiq/web'
Sidekiq::Web.use Rack::Session::Cookie, :secret => "SOMETHING SECRET"
Sidekiq::Web.instance_eval { @middleware.reverse! } # Last added, First Run

run Rack::URLMap.new('/' => WebhookConnector::GoogleSheets, '/sidekiq' => Sidekiq::Web)