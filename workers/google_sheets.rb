class GoogleSheetsWorker
	include Sidekiq::Worker
	# $redis = Redis.new

	def perform(client_id, client_secret, refresh_token, label, spreadsheet_title, worksheet_title, data)
    	# $redis.lpush("google_sheets_data", store_data(credentials, spreadsheet_title, data))
spreadsheet_title = "[#{label}] #{spreadsheet_title}"
		   client = OAuth2::Client.new(client_id, client_secret, site: "https://accounts.google.com", token_url: "/o/oauth2/token", authorize_url: "/o/oauth2/auth")
	   auth_token = OAuth2::AccessToken.from_hash(client,{:refresh_token => refresh_token, :expires_at => 3600})
	   auth_token = auth_token.refresh!
		  session = GoogleDrive.login_with_oauth(auth_token.token)
	  spreadsheet = session.spreadsheet_by_title(spreadsheet_title)
		worksheet = spreadsheet.worksheet_by_title(worksheet_title)
			  row = JSON.parse(data)
			  row['created_at'] = Time.now.to_s
	# row['abandoned_at_hkt'] = '=TEXT((INDIRECT(ADDRESS(ROW(),COLUMN()+1))*0.001)/(60*60*24)+DATE(1970,1,1)+ TIME(8,0,0),"yyyy/mm/dd hh:mm:ss")'
	# ap row['abandoned_at']
	worksheet.list.push(row)
	worksheet.save

	end
 end