# frozen_string_literal: true

require_relative './base_promotion_service'

class OrderOverAmountPercentOffMaxDiscountPerPersonPromotionService < BasePromotionService
  def initialize(user_id:, products:, promotion:, promotion_logs:)
    super(user_id: user_id, products: products, promotion: promotion, promotion_logs: promotion_logs)
  end

  def perform
    return false unless qualified_over_amount?
    return false unless qualified_per_person_max_amount?

    calculate_discount_amount
    true
  end

  private

  def qualified_over_amount?
    origin_amount >= @promotion.options[:over_amount]
  end

  def qualified_per_person_max_amount?
    user_applied_promotion_logs.sum(&:discount_amount) + present_discount_amount <= @promotion.options[:max_discount_amount]
  end

  def present_discount_amount
    @origin_amount - (@origin_amount * (1 - (@promotion.options[:percent_off].to_f / 100)))
  end

  def origin_amount
    @origin_amount ||= @products.map(&:price).sum
  end

  def calculate_discount_amount
    @discount_amount = present_discount_amount
  end

  def user_applied_promotion_logs
    @promotion_logs.select { |log| log.user_id == @user_id && log.promotion_id == @promotion.id }
  end
end
