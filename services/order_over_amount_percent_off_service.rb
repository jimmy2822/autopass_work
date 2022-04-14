# frozen_string_literal: true

class OrderOverAmountPercentOffService
  attr_accessor :products
  attr_reader :discount_amount

  def initialize(products:, options:)
    @products = products
    @options = options
  end

  def perform
    return false unless qualified_amount?

    calculate_discount_amount
    true
  end

  private

  def qualified_amount?
    origin_amount >= @options[:over_amount]
  end

  def origin_amount
    @origin_amount ||= @products.map(&:price).sum
  end

  def calculate_discount_amount
    @discount_amount = @origin_amount - (@origin_amount * (1 - (@options[:percent_off].to_f / 100)))
  end
end
