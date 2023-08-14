# frozen_string_literal: true
require 'pry'

class LoanDecisionsController < ApplicationController
  DEFAULT_ITEMS_LIST = %w[rock paper scissors].freeze

  def index; end

  def new
    @result = DecisionsEngine.new(*params_list).call
  end

  private

  def params_list
    params.require(%i[personal_code loan_amount loan_period])
  end
end
