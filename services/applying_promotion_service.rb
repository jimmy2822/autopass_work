# frozen_string_literal: true

require 'logger'

require_relative '../models/promotion'
require_relative './promotion/multiple_products_discount_amount_promotion_service'
require_relative './promotion/order_over_amount_percent_off_promotion_service'
require_relative './promotion/order_over_amount_free_product_promotion_service'
require_relative './promotion/order_over_amount_discount_amount_promotion_service'
require_relative './promotion/order_over_amount_percent_off_max_discount_per_person_promotion_service'
require_relative './promotion/order_over_amount_discount_amount_monthly_max_promotion_service'

class ApplyingPromotionService
  attr_reader :discount_amount, :result_amount, :promotions,
              :applied_promotions, :promotion_free_products, :products

  def initialize(order:, promotions:, promotion_logs:)
    @order = order
    @promotions = promotions
    @promotion_logs = promotion_logs
    @discount_amount = 0
    @result_amount = 0
    @applied_promotions = []
    @promotion_free_products = []
    @logger = Logger.new($stdout)
  end

  def perform
    apply_promotions
    calculate_result_amount
  end

  private

  def get_promotion_service_class(code)
    service_name = code.split('_').collect!(&:capitalize).join + 'PromotionService'
    Object.const_get(service_name)
  end

  def calculate_result_amount
    @order.origin_amount - @discount_amount
  end

  def apply_promotions
    @promotions.each do |promotion|
      promotion_service = get_promotion_service_class(promotion.code)
                          .new(user_id: @order.user_id, products: @order.products,
                               promotion: promotion, promotion_logs: @promotion_logs)
      next unless promotion_service.perform

      @applied_promotions << promotion
      @promotion_free_products.concat(retrieve_promotion_free_products(promotion)) if free_product_promotion?(promotion)
      @discount_amount += promotion_service.discount_amount
    rescue NameError => e
      @logger.warn("Applying Promotion: #{promotion.name} error. reason: #{e.message}")
      next
    end
  end

  def retrieve_promotion_free_products(promotion)
    free_products = []
    promotion.options[:free_product_quantity].times do
      free_products << Product.new(id: promotion.options[:free_product_id], name: 'Free Promotion Product', price: 0)
    end
    free_products
  end

  def free_product_promotion?(promotion)
    promotion.options.keys.include?(:free_product_id)
  end
end
