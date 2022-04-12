# frozen_string_literal: true

require_relative './applying_product_promotion_service'

class ProductDiscountCalculationService
  attr_accessor :products
  attr_reader :discount_amount, :result_amount, :applied_promotions

  def initialize(products:)
    @products = products
  end

  def perform
    apply_promotion_service = ApplyingProductPromotionService.new(products: @products)
    apply_promotion_service.perform
    @discount_amount = apply_promotion_service.discount_amount
    @result_amount = apply_promotion_service.result_amount
    @applied_promotions = apply_promotion_service.applied_promotions
  end
end
