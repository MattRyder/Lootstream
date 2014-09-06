class WagersController < ApplicationController
  before_action :set_wager, only: [:show, :edit, :update, :destroy]
  before_action :get_stream, only: [:index, :create]

  # GET /wagers
  # GET /wagers.json
  def index
    @wagers = Wager.where(stream: @stream)
  end

  def place_bet
    #Validate Amount:
    amount = params[:amount].to_i
    wager = WagerOption.find(params[:wager_option_id]).wager

    if amount < wager.min_amount
      error_message = "Amount must be above $#{wager.min_amount.to_i}"
    elsif amount > wager.max_amount
      error_message = "Amount must be under $#{wager.max_amount.to_i}"
    end

    if !error_message
      transaction = Transaction.create(
        amount: params[:amount],
        wager_option_id: params[:wager_option_id],
        user_id: current_user.id)

      stream = WagerOption.find(params[:wager_option_id]).wager.stream
      balance = current_user.balances(stream_id: stream).first
      balance.change(-amount)

      render json: { success: true, new_balance: balance.balance }
    else
      render json: { success: false, error_message: error_message}
    end
  end

  def distribute_winnings
    option = WagerOption.find(params[:selected_option])
    stream = option.wager.stream

    if option
      wager = option.wager
      one_pct = wager.total_amount_bet * 0.01
      p "--- REVENUE FOR STREAMER + BETSTREAM: $#{one_pct}"

      # give the option to the game, let it grab the transactions
      redeposits = wager.game.calculate_winnings(wager, option) || []

      redeposits.each do |uid, amt|
        user = User.find(uid)
        balance = user.stream_balance(stream)
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
    @wager.stream = @stream

    respond_to do |format|
      if @wager.save
        format.html { redirect_to @stream, notice: 'Wager was successfully created.' }
        format.json { render :show, status: :created, location: @wager }
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
    @wager.destroy
    respond_to do |format|
      format.html { redirect_to wagers_url, notice: 'Wager was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_wager
      @wager = Wager.find(params[:id])
    end

    def get_stream
      @stream = Stream.find_by(slug: params[:stream_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wager_params
      params.require(:wager).permit(:game_id, :question, :min_amount, :max_amount,
        wager_options_attributes: [:id, :text, :_destroy])
    end
end
