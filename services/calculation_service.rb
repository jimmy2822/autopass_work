# frozen_string_literal: true

require_relative './applying_product_promotion_service'
require_relative './applying_order_promotion_service'

class CalculationService
  attr_accessor :products
  attr_reader :origin_amount, :discount_amount, :result_amount,
              :applied_promotions, :promotion_free_products

  def initialize(products: [])
    @products = products
    @discount_amount = 0
    @applied_promotions = []
    @promotion_free_products = []
  end

  def perform
    calculate_origin_amount
    calculate_products_discount_amount
    calculate_order_discount_amount
    calculate_result_amount
  end

  private

  def calculate_origin_amount
    @origin_amount = @products.map(&:price).sum
  end

  def calculate_products_discount_amount
    applying_product_promotion_service = ApplyingProductPromotionService.new(products: @products)
    return unless applying_product_promotion_service.perform

    @discount_amount += applying_product_promotion_service.discount_amount
    @applied_promotions.concat(applying_product_promotion_service.applied_promotions)
    @promotion_free_products.concat(applying_product_promotion_service.promotion_free_products)
  end

  def calculate_order_discount_amount
    applying_order_promotion_service = ApplyingOrderPromotionService.new(products: @products)
    return unless applying_order_promotion_service.perform

    @discount_amount += applying_order_promotion_service.discount_amount
    @applied_promotions.concat(applying_order_promotion_service.applied_promotions)
    @promotion_free_products.concat(applying_order_promotion_service.promotion_free_products)
  end

  def calculate_result_amount
    @result_amount = @origin_amount - @discount_amount
  end
end
