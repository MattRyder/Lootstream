module WagersHelper

  def odds(option)
    wager = option.wager

    amt_total = wager.total_amount_bet.to_i
    amt_option = option.amount_bet.to_i
    amt_total -= amt_option

    div_factor = amt_total.gcd(amt_option)

    while div_factor > 1
      amt_total /= div_factor
      amt_option /= div_factor
      div_factor = amt_total.gcd(amt_option)
    end

    "#{amt_option.zero? ? 1 : amt_option} / #{amt_total.zero? ? 1 : amt_total}"
  end

end
