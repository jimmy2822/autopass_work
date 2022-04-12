# frozen_string_literal: true

class Promotion
  attr_accessor :id, :name, :code, :promotion_target_type, :quantity,
                :options

  def initialize(id:, name:, code:, promotion_target_type:,
                 quantity: nil, options: {})
    @id = id
    @name = name
    @code = code
    @promotion_target_type = promotion_target_type
    @quantity = quantity
    @options = options
  end
end
