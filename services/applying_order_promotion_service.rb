# frozen_string_literal: true

require_relative './applying_promotion_base_service'
require_relative './order_over_amount_percent_off_service'
require_relative './order_over_amount_free_product_service'

class ApplyingOrderPromotionService < ApplyingPromotionBaseService
  # promotions 可由後台人員操作新增
  def retrieve_promotions
    @promotions << Promotion.new(id: 2, name: '訂單滿 1000 元折 10%', code: 'order_over_amount_percent_off',
                                 promotion_target_type: 'ORDER',
                                 options: { over_amount: 1000, percent_off: 10 })
    @promotions << Promotion.new(id: 3, name: '訂單滿 2000 元贈送面紙一盒', code: 'order_over_amount_free_product',
                                 promotion_target_type: 'ORDER',
                                 options: { over_amount: 2000, free_product_id: 3, free_product_quantity: 1 })
  end
end
