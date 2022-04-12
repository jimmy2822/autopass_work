# frozen_string_literal: true

class ApplyingPromotionBaseService
  attr_accessor :products
  attr_reader :discount_amount, :result_amount, :promotions, :applied_promotions

  def initialize(products:)
    @discount_amount = 0
    @result_amount = 0
    @products = products
    @promotions = []
    @applied_promotions = []
  end

  def perform
    retrieve_promotions
    apply_promotions
    calculate_result_amount
  end

  def retrieve_promotions
    raise NotImplementedError
  end

  def apply_promotions
    raise NotImplementedError
  end

  private

  def get_promotion_service_class(code)
    service_name = code.split('_').collect!(&:capitalize).join + 'Service'
    Object.const_get(service_name)
  end

  def calculate_result_amount
    @products.map(&:price).sum - @discount_amount
  end
end
