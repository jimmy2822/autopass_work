# frozen_string_literal: true

class Product
  attr_accessor :id, :name, :price

  def initialize(id:, name:, price:)
    @id = id
    @name = name
    @price = price
  end
end
