# frozen_string_literal: true

require_relative './base_promotion_service'

class OrderOverAmountDiscountAmountMonthlyMaxPromotionService < BasePromotionService
  def initialize(user_id:, products:, promotion:, promotion_logs:)
    super(user_id: user_id, products: products, promotion: promotion, promotion_logs: promotion_logs)
  end

  def perform
    return false unless qualified_over_amount?
    return false unless qualified_monthly_max_amount?

    calculate_discount_amount
    true
  end

  private

  def qualified_over_amount?
    origin_amount >= @promotion.options[:over_amount]
  end

  def qualified_monthly_max_amount?
    applied_promotion_logs.sum(&:discount_amount) + present_discount_amount <= @promotion.options[:monthly_max_amount]
  end

  def present_discount_amount
    @promotion.options[:discount_amount]
  end

  def origin_amount
    @origin_amount ||= @products.map(&:price).sum
  end

  def calculate_discount_amount
    @discount_amount = present_discount_amount
  end

  def applied_promotion_logs
    @promotion_logs.select { |log| log.promotion_id == @promotion.id && log.created_at.month == DateTime.now.month }
  end
end
