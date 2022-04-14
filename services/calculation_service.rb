# frozen_string_literal: true

require_relative './applying_product_promotion_service'

class CalculationService
  attr_accessor :products
  attr_reader :origin_amount, :discount_amount, :result_amount, :applied_promotions

  def initialize(products: [])
    @products = products
    @discount_amount = 0
    @applied_promotions = []
  end

  def perform
    calculate_origin_amount
    calculate_products_discount_amount
    calculate_result_amount
  end

  private

  def calculate_origin_amount
    @origin_amount = @products.map(&:price).sum
  end

  def calculate_products_discount_amount
    product_discount_service = ApplyingProductPromotionService.new(products: @products)
    product_discount_service.perform
    @discount_amount += product_discount_service.discount_amount
    @applied_promotions.concat(product_discount_service.applied_promotions)
  end

  def calculate_result_amount
    @result_amount = @origin_amount - @discount_amount
  end
end
