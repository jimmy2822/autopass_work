# frozen_string_literal: true

class OrderOverAmountDiscountAmountService
  attr_accessor :products
  attr_reader :discount_amount, :promotion

  def initialize(products:, promotion:)
    @products = products
    @promotion = promotion
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
