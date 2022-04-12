# frozen_string_literal: true

require_relative './applying_promotion_base_service'
require_relative './multiple_products_promotion_service'
require_relative '../models/promotion'

class ApplyingProductPromotionService < ApplyingPromotionBaseService
  # promotions 可由後台人員操作新增
  def retrieve_promotions
    @promotions << Promotion.new(id: 1, name: '特定商品滿 2 件折 100 元', code: 'multiple_products_promotion',
                                 promotion_target_type: 'PRODUCT',
                                 options: { promotion_product_ids: [1, 2], quantity: 2, discount_amount: 100 })
  end

  def apply_promotions
    @promotions.each do |promotion|
      promotion_service = get_promotion_service_class(promotion.code)
                          .new(products: @products, options: promotion.options)
      next unless promotion_service.perform

      @applied_promotions << promotion
      @discount_amount += promotion_service.discount_amount
    end
  end
end
