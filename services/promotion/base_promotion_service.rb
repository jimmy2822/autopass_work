# frozen_string_literal: true

class BasePromotionService
  attr_reader :user_id, :products, :promotion, :discount_amount, :promotion_logs

  def initialize(user_id:, products:, promotion:, promotion_logs:)
    @user_id = user_id
    @products = products
    @promotion = promotion
    @promotion_logs = promotion_logs
  end
end
