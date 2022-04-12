# frozen_string_literal: true

class MultipleProductsPromotionService
  attr_accessor :products
  attr_reader :discount_amount

  def initialize(products:, options:)
    @products = products
    @options = options
    @qualified_products = []
  end

  def perform
    retrieve_qualified_products

    return false if @qualified_products.count.zero?

    calculate_discount_amount
    true
  end

  private

  def retrieve_qualified_products
    @products.each do |product|
      next unless promotion_product?(product.id) && qualified_quantity?(product.id)

      @qualified_products << product
    end
  end

  def promotion_product?(product_id)
    @options[:promotion_product_ids].include?(product_id)
  end

  def qualified_quantity?(product_id)
    @products.select { |product| product.id == product_id }.count >= @options[:quantity]
  end

  def calculate_discount_amount
    @discount_amount = @qualified_products.map(&:id).uniq.count * @options[:discount_amount]
  end
end
