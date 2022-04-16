# frozen_string_literal: true

require_relative './base_promotion_service'

class OrderOverAmountPercentOffPromotionService < BasePromotionService
  def initialize(user_id:, products:, promotion:, promotion_logs:)
    super(user_id: user_id, products: products, promotion: promotion, promotion_logs: promotion_logs)
  end

  def perform
    return false unless qualified_amount?

    calculate_discount_amount
    true
  end

  private

  def qualified_amount?
    origin_amount >= @promotion.options[:over_amount]
  end

  def origin_amount
    @origin_amount ||= @products.map(&:price).sum
  end

  def calculate_discount_amount
    @discount_amount = @origin_amount - (@origin_amount * (1 - (@promotion.options[:percent_off].to_f / 100)))
  end
end
