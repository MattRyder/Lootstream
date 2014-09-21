class WagersController < ApplicationController
  before_action :set_wager, only: [:show, :edit, :update, :destroy]
  before_action :get_channel, only: [:index, :create]

  helper_method :calculate_odds

  # GET /wagers
  # GET /wagers.json
  def index
    @wagers = Wager.where(channel: @channel)
  end

  def place_bet
    #Validate Amount:
    amount = params[:amount].to_i
    wager = WagerOption.find(params[:wager_option_id]).wager
    bal = current_user.channel_balance(wager.channel)

    if amount < wager.min_amount
      error_message = "Amount must be above $#{wager.min_amount.to_i}"
    elsif amount > wager.max_amount
      error_message = "Amount must be under $#{wager.max_amount.to_i}"
    elsif bal.balance - amount < 0
      error_message = "Not enough balance!"
    end

    if !error_message
      transaction = Transaction.create(
        amount: params[:amount],
        wager_option_id: params[:wager_option_id],
        user_id: current_user.id)

      bal.change(-amount)
      render json: { success: true, new_balance: bal.balance }
    else
      render json: { success: false, error_message: error_message}
    end
  end

  def distribute_winnings
    option = WagerOption.find(params[:selected_option])
    channel = option.wager.channel

    if option
      wager = option.wager
      wager.set_winner(option.id)
      one_pct = wager.total_amount_bet * 0.01
      p "--- REVENUE FOR STREAMER + BETSTREAM: $#{one_pct}"

      # give the option to the game, let it grab the transactions
      redeposits = wager.game.calculate_winnings(wager, option) || []

      redeposits.each do |uid, amt|
        user = User.find(uid)
        balance = user.channel_balance(channel)
        balance.change(amt)
      end

      # Suspend the Wager, and you're done!
      wager.suspend
      status = "Wager suspended, winnings distributed"

      respond_to do |format|
        format.json { render json: { success: true, status: status }}
      end
      
    end
  end

  def process_realtime
    response = {}
    @wager = Wager.find(params[:wager_id]) unless params[:wager_id] == "0"
    
    if @wager.present?
      if @wager.active
        odds_data = []
        @wager.wager_options.each do |option|
          odds_data << { id: option.id, value: option.calculate_odds }
        end
        response[:odds] = odds_data.to_json
      elsif params[:uid].present?
        transaction = @wager.user_transaction(params[:uid].to_i)
        if transaction
          response[:wager_state] = {
            state: transaction.wager_option.won ? "won" : "lost",
            amount: transaction.amount,
            winopt: @wager.winning_option
          }
        end
      end
    end

    render json: response

  end

  # GET /wagers/1
  # GET /wagers/1.json
  def show
    @summary = @wager.transaction_data || []
  end

  # GET /wagers/new
  def new
    @wager = Wager.new
  end

  # GET /wagers/1/edit
  def edit
  end

  # POST /wagers
  # POST /wagers.json
  def create
    @wager = Wager.new(wager_params)
    @wager.channel = @channel

    byebug

    respond_to do |format|
      if @wager.save
        format.html { redirect_to @channel, notice: 'Wager was successfully created.' }
        format.json { render @wager, status: :created }
      else
        format.html { render :new }
        format.json { render json: @wager.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /wagers/1
  # PATCH/PUT /wagers/1.json
  def update
    respond_to do |format|
      if @wager.update(wager_params)
        format.html { redirect_to @wager, notice: 'Wager was successfully updated.' }
        format.json { render :show, status: :ok, location: @wager }
      else
        format.html { render :edit }
        format.json { render json: @wager.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /wagers/1
  # DELETE /wagers/1.json
  def destroy
    @wager.suspend
    respond_to do |format|
      format.html { redirect_to channel_url(@wager.channel), notice: 'Wager was successfully suspended.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wager
      @wager = Wager.find(params[:id])
    end

    def get_channel
      @channel = Channel.friendly.find(params[:channel_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wager_params
      params.require(:wager).permit(:game_id, :question, :min_amount, :max_amount,
        wager_options_attributes: [:id, :text, :_destroy])
    end
end
