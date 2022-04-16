# frozen_string_literal: true

class PromotionLog
  attr_accessor :id, :user_id, :promotion_id, :discount_amount, :created_at

  def initialize(id:, user_id:, promotion_id:, discount_amount:, created_at: DateTime.now)
    @id = id
    @user_id = user_id
    @promotion_id = promotion_id
    @discount_amount = discount_amount
    @created_at = created_at
  end
end
