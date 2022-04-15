# frozen_string_literal: true

require_relative './applying_promotion_service'

class CalculationService
  attr_accessor :products, :promotions
  attr_reader :origin_amount, :discount_amount, :result_amount,
              :applied_promotions, :promotion_free_products

  def initialize(products: [], promotions: [])
    @products = products
    @promotions = promotions
    @discount_amount = 0
    @applied_promotions = []
    @promotion_free_products = []
  end

  def perform
    calculate_origin_amount
    apply_promotions
    calculate_result_amount
  end

  private

  def calculate_origin_amount
    @origin_amount = @products.map(&:price).sum
  end

  def apply_promotions
    applying_promotion_service = ApplyingPromotionService.new(products: @products, promotions: @promotions)
    return unless applying_promotion_service.perform

    @discount_amount += applying_promotion_service.discount_amount
    @applied_promotions.concat(applying_promotion_service.applied_promotions)
    @promotion_free_products.concat(applying_promotion_service.promotion_free_products)
  end

  def calculate_result_amount
    @result_amount = @origin_amount - @discount_amount
  end
end
