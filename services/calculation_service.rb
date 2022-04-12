# frozen_string_literal: true

require_relative './product_discount_calculation_service'

class CalculationService
  attr_accessor :products
  attr_reader :origin_amount, :discount_amount, :result_amount

  def initialize(products: [])
    @products = products
    @discount_amount = 0
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
    product_discount_service = ProductDiscountCalculationService.new(products: @products)
    product_discount_service.perform
    @discount_amount += product_discount_service.discount_amount
  end

  def calculate_result_amount
    @result_amount = @origin_amount - @discount_amount
  end
end
