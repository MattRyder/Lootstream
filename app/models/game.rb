class Game < ActiveRecord::Base

  def calculate_winnings(wager, winning_option)
    
    # Redeposit, win + original bet, to be recredited:
    redeposit_amounts = {}
    # get losing option
    losing_option = wager.wager_options.where
                    .not(id: winning_option.id).first

    return if losing_option.transactions.empty? || winning_option.transactions.empty?

    win_total = winning_option.transactions.map(&:amount).reduce(:+)
    loss_total = losing_option.transactions.map(&:amount).reduce(:+)

    total_pot = win_total + loss_total

    # find the share% of how much each is of the total
    win_share = (win_total/total_pot)
    loss_share = (loss_total/total_pot)
    one_pct = (total_pot / 100)

    host_share = (win_share+loss_share * one_pct)
    p "-- Host takes #{host_share}"

    win_total -= (win_share * one_pct)
    loss_total -= (loss_share * one_pct)

    winning_option.transactions.each do |win_trans|
      # Percentage of the total winning pot
      pot_percentage = (win_trans.amount / win_total).round(2)

      # Winnings are <pot_pct>% of the losing pot
      winnings = loss_total * pot_percentage
      redeposit_amounts[win_trans.user.id] = (win_trans.amount + winnings)
      p "--- User #{win_trans.user.id} wins $#{winnings} on $#{win_trans.amount} bet"

      # Set this transaction as a winner:
      win_trans.update_attribute(won: true)
    end

    redeposit_amounts
  end
end
