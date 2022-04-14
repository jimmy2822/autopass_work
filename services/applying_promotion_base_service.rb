# frozen_string_literal: true

require_relative '../models/promotion'

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

  private

  def get_promotion_service_class(code)
    service_name = code.split('_').collect!(&:capitalize).join + 'Service'
    Object.const_get(service_name)
  end

  def calculate_result_amount
    @products.map(&:price).sum - @discount_amount
  end

  def apply_promotions
    @promotions.each do |promotion|
      promotion_service = get_promotion_service_class(promotion.code)
                          .new(products: @products, options: promotion.options)
      next unless promotion_service.perform

      @applied_promotions << promotion
      @discount_amount += promotion_service.discount_amount
    rescue => e
      puts(promotion.name, 'Applying error with message: ', e.message)
      next
    end
  end
end
