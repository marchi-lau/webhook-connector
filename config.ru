require './connectors'

Sidekiq::Web.use Rack::Session::Cookie, :secret => "SOMETHING SECRET"
Sidekiq::Web.instance_eval { @middleware.reverse! } # Last added, First Run

map "/google-sheets" do
	run WebhookConnector::GoogleSheets
end

map "/push-notifier" do
	run WebhookConnector::PushNotifier
end

map "/sidekiq" do
	run Sidekiq::Web
end
