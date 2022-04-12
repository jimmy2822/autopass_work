# frozen_string_literal: true

class Order
  attr_accessor :id, :user_id, :origin_price_total, :discount_total

  def initialize(id:, user_id:, origin_amount:, discount_amount:, result_amount:)
    @id = id
    @user_id = user_id
    @origin_amount = origin_amount
    @discount_amount = discount_amount
    @result_amount = result_amount
  end
end
