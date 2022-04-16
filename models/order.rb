# frozen_string_literal: true

class Order
  attr_accessor :discount_amount
  attr_reader :id, :user_id, :products

  def initialize(id:, user_id:, products:)
    @id = id
    @user_id = user_id
    @products = products
  end

  def origin_amount
    @products.sum(&:price)
  end

  def result_amount
    @origin_amount - @discount_amount
  end
end
