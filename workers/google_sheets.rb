class GoogleSheetsWorker
	include Sidekiq::Worker
	# $redis = Redis.new

	def perform(client_id, client_secret, refresh_token, label, spreadsheet_title, worksheet_title, data)
		# if client_id == "185317710886-ukv91jn2cmb96h0uiquniqaph97delbk.apps.googleusercontent.com"
		  google_client = Google::APIClient.new
		  google_client.authorization.client_id = client_id
		  google_client.authorization.client_secret = client_secret
		  google_client.authorization.refresh_token = refresh_token
  		google_client.authorization.scope = ["https://www.googleapis.com/auth/drive", "https://spreadsheets.google.com/feeds/"]
  		google_client.authorization.redirect_uri = "urn:ietf:wg:oauth:2.0:oob"
		   auth_token = google_client.authorization.fetch_access_token!
		  	  session = GoogleDrive.login_with_oauth(auth_token["access_token"])

	spreadsheet_title = "[#{label}] #{spreadsheet_title}"
		  spreadsheet = session.spreadsheet_by_title(spreadsheet_title)
			worksheet = spreadsheet.worksheet_by_title(worksheet_title)
				  ap row = JSON.parse(data)
			  #Prettify Column
			  row.update(row.select{|key, value| key.to_s.include?(":epoch")}){|key, value| value = (Time.at(value.to_i/1000)).strftime("%d/%m/%Y %H:%M")}
			  row['created_at'] = (Time.now + 8*60*60).strftime("%d/%m/%Y %H:%M")
	# row['abandoned_at_hkt'] = '=TEXT((INDIRECT(ADDRESS(ROW(),COLUMN()+1))*0.001)/(60*60*24)+DATE(1970,1,1)+ TIME(8,0,0),"yyyy/mm/dd hh:mm:ss")'
	# ap row['abandoned_at']
	worksheet.list.push(row)
	worksheet.save
	# end
end
 end


