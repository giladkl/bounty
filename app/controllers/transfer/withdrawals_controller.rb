module Transfer
	class WithdrawalsController < ApplicationController
		before_action :authenticate_user!, except: [:index, :show]
		before_action :define_user

		def create
			withdrawal = Withdrawal.new
			withdrawal.amount = params[:amount]
			withdrawal.user = current_user

			#Check that user has enough money in his account to make this withdrawal
			if (current_user.balance - withdrawal.amount) < 0
				logger.info "User tried to withdraw more then he has in his balance"
				render :plain => "Don't. Just don't. You seriously thought that would work? Well fuck you cause I'm smarter then you and I fucked your mom so stfu."
				return
			end
			@payout = Payout.new(
			  {
			    :sender_batch_header => {
			      :sender_batch_id => SecureRandom.hex(8),
			      :email_subject => 'Withdrawal from Bounty',
			    },
			    :items => [
			      {
			        :recipient_type => 'EMAIL',
			        :amount => {
			          :value => withdrawal.amount,
			          :currency => 'USD'
			        },
			        :note => 'Bounty loves you!',
			        :receiver => current_user.email,
			        :sender_item_id => "0",
			      }
			    ]
			  }
			)

			begin
			  @payout_batch = @payout.create
			  withdrawal.payout_batch_id = @payout_batch.batch_header.payout_batch_id
			  withdrawal.save

			  current_user.balance -= withdrawal.amount
			  current_user.save
			  
			  logger.info "Created Payout with [#{@payout_batch.batch_header.payout_batch_id}]"
			rescue ResourceNotFound => err
			  logger.error @payout.error.inspect
		end

		


	end
end