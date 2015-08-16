class GoogleSheetsController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [:create_rows]

	def create_rows
		  ap row = ActiveSupport::JSON.decode(request.body.read)
		  row['abandoned_at_hkt'] = '=TEXT((INDIRECT(ADDRESS(ROW(),COLUMN()+1))*0.001)/(60*60*24)+DATE(1970,1,1)+ TIME(8,0,0),"yyyy/mm/dd hh:mm:ss")'
		  spreadsheet_title = "[#{params[:label]}] " + params[:spreadsheet_title]
		  worksheet_title = params[:worksheet_title]
				client_id = cookies[:client_id]
			client_secret = cookies[:client_secret]
			refresh_token = cookies[:refresh_token]
			   client = OAuth2::Client.new(client_id, client_secret, site: "https://accounts.google.com", token_url: "/o/oauth2/token", authorize_url: "/o/oauth2/auth")
		   auth_token = OAuth2::AccessToken.from_hash(client,{:refresh_token => refresh_token, :expires_at => 3600})
		   auth_token = auth_token.refresh!
			  session = GoogleDrive.login_with_oauth(auth_token.token)
		  spreadsheet = session.spreadsheet_by_title(spreadsheet_title)
			worksheet = spreadsheet.worksheet_by_title(worksheet_title)
			worksheet.list.push(row)
			ap worksheet.save
			render :inline => "200"
	end
end
