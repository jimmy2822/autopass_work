# frozen_string_literal: true

require_relative '../models/promotion'
require 'logger'

class ApplyingPromotionBaseService
  attr_accessor :products
  attr_reader :discount_amount, :result_amount, :promotions,
              :applied_promotions, :promotion_free_products

  def initialize(products:)
    @discount_amount = 0
    @result_amount = 0
    @products = products
    @promotions = []
    @applied_promotions = []
    @promotion_free_products = []
    @logger = Logger.new($stdout)
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
