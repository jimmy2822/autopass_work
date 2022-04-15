# frozen_string_literal: true

class Promotion
  attr_accessor :id, :name, :code, :promotion_target_type,
                :options
  attr_reader :quantity

  def initialize(id:, name:, code:, promotion_target_type:,
                 quantity: nil, options: {})
    @id = id
    @name = name
    @code = code
    @promotion_target_type = promotion_target_type
    @quantity = quantity
    @options = options
  end

  def limited_quantity?
    quantity != nil
  end

  def sufficient_quantity?
    limited_quantity? && quantity.positive?
  end

  def quantity=(amount)
    raise 'Quantity can not be less than zero' if amount.negative?

    @quantity = amount
  end
end
