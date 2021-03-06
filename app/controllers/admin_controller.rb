class AdminController < ApplicationController
	before_action :authenticate_admin!
	layout 'dashboard'

	def index
		@users = User.all.count
		@wifis = Wifi.all
		@connections = Connection.all
		@total_earning = 0
		@download_data = 0
		@upload_data = 0
		@connected_user = Connection.where(disconnected_at: nil).count
		Connection.all.each do |conn|
			@total_earning = @total_earning + conn.total_bill
			@download_data = @download_data + conn.download_data
			@upload_data = @upload_data + conn.upload_data
		end
	end

	def wifi_table
		@wifi = Wifi.all.order(updated_at: 'DESC')
	end

	def wifi_map
		@wifi = Wifi.all
	end

	def users
		@user = User.all.order(updated_at: 'DESC')
	end

	def connections
		@connection = Connection.all.order(updated_at: 'DESC')
		@total_earning = 0
		@download_data = 0
		@upload_data = 0
		Connection.all.each do |conn|
			@total_earning = @total_earning + conn.total_bill
			@download_data = @download_data + conn.download_data
			@upload_data = @upload_data + conn.upload_data
		end
	end

	def payments
		@wifi = Wifi.all
		@wifi_earning = ''
		@wifi_conn = ''
		@total_earning = 0
		@avg_con = ( Connection.all.count / Wifi.all.count ).round
		Connection.all.each do |conn|
			@total_earning = @total_earning + conn.total_bill
		end
		Wifi.all.order(updated_at: 'DESC').limit(50).each do |wif|
			
			temp_wifi_earning = ''
			wif.connections.each do |coni|
				if(temp_wifi_earning == '')
					temp_wifi_earning = ((coni.total_bill)/1000).round(2).to_s
				else
					temp_wifi_earning = temp_wifi_earning + ","+ ((coni.total_bill)/1000).round(2).to_s
				end
			end
			if(@wifi_earning == '' || @wifi_conn)
				@wifi_earning = temp_wifi_earning
				@wifi_conn = wif.connections.count.to_s
			else
				@wifi_earning = @wifi_earning + ","+ temp_wifi_earning
				@wifi_conn = @wifi_conn + "," + wif.connections.count.to_s
			end
		end
	end

	def redir_dash
		redirect_to dashboard_path
	end

	def block_user
		user = User.find(params[:id])
		api = user.api_key.update(token: nil)
		user.update(blocked: true)
		redirect_to :back
	end

	def unblock_user
		user = User.find(params[:id])
		user.update(blocked: false)
		redirect_to :back
	end

	def block_wifi
		wifi = Wifi.find(params[:id])
		wifi.update(blocked: true)
		redirect_to :back
	end

	def unblock_wifi
		wifi = Wifi.find(params[:id])
		wifi.update(blocked: false)
		redirect_to :back
	end

	def reset_pass
		p params
		if params[:password] == params[:c_password]
			user = User.find(params[:id])
			user.update(password: params[:password])
		end
		redirect_to :back
	end

	def block
		@user = User.all
		@user_block = User.where(blocked: true)
		@wifi = Wifi.all
		@wifi_block = Wifi.where(blocked: true)
	end

	def stats
		@connections = Connection.where.not(disconnected_at: nil).order(updated_at: 'DESC').limit(10)
		@wifis = []
		id_chk = []
		Connection.all.order(updated_at: 'DESC').each do |conn|
			if id_chk.include? conn.wifi_id

			else
				if id_chk.count < 30
					if conn.wifi.present?
						@wifis.push(conn.wifi)
					end
					id_chk.push(conn.wifi_id)
				else
					break
				end
			end
		end
		p "Wifis"
		p @wifis
	end

	def stripe_account_list
		require "stripe"
		Stripe.api_key = "sk_test_9VYi8WoB1EmZIrmrdNLgXR6U"

		@str =  Stripe::Charge.list(:limit => 100)
	end

	def stripe_account_refund
		require "stripe"
		Stripe.api_key = "sk_test_9VYi8WoB1EmZIrmrdNLgXR6U"

		re = Stripe::Refund.create(
		  charge: params[:ch_tok]
		)
		redirect_to :back
	end

	def term_success_false
		@user = User.where(terminated_successfully: false)
	end

	def term_success_mark_true
		user = User.find(params[:id])
		user.update(terminated_successfully: true)
		redirect_to :back
	end

	def withdraw_pending
		@withdraw = Withdraw.where(transfered: false)
	end

	def withdraw_transferred
		@withdraw = Withdraw.where(transfered: true)
	end

	def mark_withdraw_pending
		c = Withdraw.find(params[:id])
		c.update(transfered: true)
		redirect_to :back
	end

	def delete_user
		user = User.find(params[:id])
		user.destroy
		redirect_to :back
	end
end