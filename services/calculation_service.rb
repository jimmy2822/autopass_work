# frozen_string_literal: true

require_relative './applying_promotion_service'

class CalculationService
  attr_reader :order, :promotions, :promotion_logs, :discount_amount, :result_amount,
              :applied_promotions, :promotion_free_products

  def initialize(order:, promotions: [], promotion_logs: [])
    @order = order
    @promotions = promotions
    @promotion_logs = promotion_logs
    @discount_amount = 0
    @applied_promotions = []
    @promotion_free_products = []
  end

  def perform
    apply_promotions
    calculate_result_amount
  end

  def origin_amount
    @order.origin_amount
  end

  private

  def apply_promotions
    applying_promotion_service = ApplyingPromotionService.new(order: @order, promotions: @promotions, promotion_logs: @promotion_logs)
    return unless applying_promotion_service.perform

    @discount_amount += applying_promotion_service.discount_amount
    @applied_promotions.concat(applying_promotion_service.applied_promotions)
    @promotion_free_products.concat(applying_promotion_service.promotion_free_products)
  end


  def calculate_result_amount
    @result_amount = @order.origin_amount - @discount_amount
  end
end
