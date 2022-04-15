# frozen_string_literal: true

class OrderOverAmountPercentOffService
  attr_accessor :products
  attr_reader :discount_amount

  def initialize(products:, promotion:)
    @products = products
    @promotion = promotion
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
