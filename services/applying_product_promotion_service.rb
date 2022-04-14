# frozen_string_literal: true

require_relative './applying_promotion_base_service'
require_relative './multiple_products_promotion_service'

class ApplyingProductPromotionService < ApplyingPromotionBaseService
  # promotions 可由後台人員操作新增
  def retrieve_promotions
    @promotions << Promotion.new(id: 1, name: '特定商品滿 2 件折 100 元', code: 'multiple_products_promotion',
                                 promotion_target_type: 'PRODUCT',
                                 options: { promotion_product_ids: [1, 2], quantity: 2, discount_amount: 100 })
  end
end
