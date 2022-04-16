# frozen_string_literal: true

require_relative './base_promotion_service'

class OrderOverAmountDiscountAmountPromotionService < BasePromotionService
  def initialize(user_id:, products:, promotion:, promotion_logs:)
    super(user_id: user_id, products: products, promotion: promotion, promotion_logs: promotion_logs)
  end

  def perform
    return false unless qualified_origin_amount?
    return false unless promotion.sufficient_quantity?

    process_promotion_quantity
    calculate_discount_amount
    true
  end

  private

  def process_promotion_quantity
    @promotion.quantity -= 1
  end

  def qualified_origin_amount?
    @products.map(&:price).sum >= @promotion.options[:over_amount]
  end

  def calculate_discount_amount
    @discount_amount = @promotion.options[:discount_amount]
  end
end
