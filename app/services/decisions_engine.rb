# frozen_string_literal: true

class DecisionsEngine
  # Should be moved in modal or settings
  MIN_LOAN_AMOUNT = 2000
  MAX_LOAN_AMOUNT = 10_000

  MIN_LOAN_PERIOD = 12
  MAX_LOAN_PERIOD = 60

  attr_accessor :personal_code, :loan_amount, :loan_period

  def initialize(personal_code, loan_amount, loan_period)
    @personal_code = personal_code
    @loan_amount = loan_amount.to_i
    @loan_period = loan_period.to_i
  end

  def call
    return rejected_by_invalid_requirments unless valid_conditions?(loan_amount, loan_period)
    return rejected_by_debt_presence if credit_modifier.zero?

    max_possible_amount = calculate_max_possible_amount_with_requested_period
    return approved_with_requested_period(max_possible_amount) if loan_amount <= max_possible_amount

    possible_amount, possible_period = find_another_loan_period_and_amount(max_possible_amount)

    if valid_conditions?(possible_amount, possible_period)
      return rejcted_with_another_amount_or_period(possible_amount, possible_period)
    end

    reject_without_any_possible_variants
  end

  private

  def valid_conditions?(amount, period)
    (MIN_LOAN_AMOUNT..MAX_LOAN_AMOUNT).include?(amount) && (MIN_LOAN_PERIOD..MAX_LOAN_PERIOD).include?(period)
  end

  def credit_modifier
    @credit_modifier ||= CreditModifierFetcher.new(personal_code).call
  end

  def calculate_max_possible_amount_with_requested_period
    max_possible_amount = loan_period * @credit_modifier
    max_possible_amount > MAX_LOAN_AMOUNT ? MAX_LOAN_AMOUNT : max_possible_amount
  end

  def find_another_loan_period_and_amount(max_possible_amount)
    return [max_possible_amount, loan_period] if max_possible_amount >= MIN_LOAN_AMOUNT

    min_possible_period = (MIN_LOAN_AMOUNT / @credit_modifier).ceil
    max_possible_amount = min_possible_period * @credit_modifier
    [max_possible_amount, min_possible_period]
  end

  def rejected_by_invalid_requirments
    {
      decision: false,
      # Should be moved to localization through i18n
      reason: 'The loan terms requested by you cannot be processed they are not included in the possible limits'
    }
  end

  def rejected_by_debt_presence
    {
      decision: false,
      # Should be moved to localization through i18n
      reason: 'You already have a debt in our bank or we don\'t have enough information about you'
    }
  end

  def approved_with_requested_period(max_possible_amount)
    {
      decision: true,
      max_possible_amount:
    }
  end

  def rejcted_with_another_amount_or_period(max_possible_amount, min_period)
    {
      decision: false,
      # Should be moved to localization through i18n
      reason: 'We can provide you loan with next conditions',
      max_possible_amount:,
      min_period:
    }
  end

  def reject_without_any_possible_variants
    {
      decision: false,
      # Should be moved to localization through i18n
      reason: 'We can\'t provide you any credit'
    }
  end
end
