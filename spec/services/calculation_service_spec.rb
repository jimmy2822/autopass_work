# frozen_string_literal: true

require 'faker'
require_relative '../../models/order'
require_relative '../../services/calculation_service'
require_relative '../../models/product'
require_relative '../../models/promotion_log'

RSpec.describe CalculationService do
  let(:user) { User.new(id: 1, name: 'Jimmy') }
  let(:order) { Order.new(id: 1, user_id: user.id, products: products ) }
  let(:promotion_logs) { [] }
  subject { CalculationService.new(order: order, promotions: promotions, promotion_logs: promotion_logs) }

  describe '#perform' do
    before { subject.perform }

    let(:promotions) do
      [
        Promotion.new(id: 1, name: '特定商品滿 2 件折 100 元', code: 'multiple_products_discount_amount',
                      promotion_target_type: 'PRODUCT',
                      options: { promotion_product_ids: [1, 2], quantity: 2, discount_amount: 100 }),
        Promotion.new(id: 2, name: '訂單滿 1000 元折 10%', code: 'order_over_amount_percent_off',
                      promotion_target_type: 'ORDER',
                      options: { over_amount: 1000, percent_off: 10 }),
        Promotion.new(id: 3, name: '訂單滿 2000 元贈送面紙一盒', code: 'order_over_amount_free_product',
                      promotion_target_type: 'ORDER',
                      options: { over_amount: 2000, free_product_id: 3, free_product_quantity: 1 }),
        Promotion.new(id: 4, name: '訂單滿 10000 元可以折 2000 元，全站限用 1 次', code: 'order_over_amount_discount_amount',
                      promotion_target_type: 'ORDER', quantity: 1,
                      options: { over_amount: 10_000, discount_amount: 2000 })
      ]
    end

    describe 'when products are not qualified any promotions' do
      let(:products) do
        [
          Product.new(id: 1, name: Faker::Commerce.product_name, price: 200) ,
          Product.new(id: 2, name: Faker::Commerce.product_name, price: 300)
        ]
      end


      it 'origin_amount is equal to products price sum' do
        expect(subject.origin_amount).to eq(500)
      end

      it 'discount amount should be 0 if there is no promotion applying' do
        expect(subject.discount_amount).to eq(0)
      end

      it 'result_amount should be origin_amount' do
        expect(subject.result_amount).to eq(500)
      end
    end

    describe 'when products are qualified to apply multiple products discount promotion' do
      let(:products) do
        [
          Product.new(id: 1, name: Faker::Commerce.product_name, price: 300),
          Product.new(id: 1, name: Faker::Commerce.product_name, price: 300)
        ]
      end

      it 'origin_amount is equal to products price sum' do
        expect(subject.origin_amount).to eq(600)
      end

      it 'discount amount should be 100 due to the promotion' do
        expect(subject.discount_amount).to eq(100)
      end

      it 'result_amount should be discounted' do
        expect(subject.result_amount).to eq(500)
      end
    end

    describe 'when order is qualified to apply order over amount percent off  promotion' do
      let(:products) do
        [
          Product.new(id: 1, name: Faker::Commerce.product_name, price: 500),
          Product.new(id: 2, name: Faker::Commerce.product_name, price: 500)
        ]
      end

      it 'origin_amount is equal to products price sum' do
        expect(subject.origin_amount).to eq(1000)
      end

      it 'discount amount should be 100 due to the promotion' do
        expect(subject.discount_amount).to eq(100)
      end

      it 'result_amount should be discounted' do
        expect(subject.result_amount).to eq(900)
      end
    end

    describe 'when order is qualified to apply order over amount free product promotion' do
      let(:products) do
        [
          Product.new(id: 1, name: Faker::Commerce.product_name, price: 1000),
          Product.new(id: 2, name: Faker::Commerce.product_name, price: 2000)
        ]
      end

      it 'origin_amount is equal to products price sum' do
        expect(subject.origin_amount).to eq(3000)
      end

      it 'discount amount should come from 10% off promotion' do
        expect(subject.discount_amount).to eq(300)
      end

      it 'result_amount should be origin_amount' do
        expect(subject.result_amount).to eq(2700)
      end

      it 'should get free product' do
        expect(subject.promotion_free_products.size).to eq(1)
      end

      it 'should get free product' do
        expect(subject.promotion_free_products.first.name).to eq('Free Promotion Product')
      end
    end

    describe 'when order is qualified to apply order over amount discount amount promotion' do
      let(:promotions) do
        [
          Promotion.new(id: 4, name: '訂單滿 10000 元可以折 2000 元，全站限用 1 次', code: 'order_over_amount_discount_amount',
                        promotion_target_type: 'ORDER', quantity: 1,
                        options: { over_amount: 10_000, discount_amount: 2000 })
        ]
      end
      let(:products) do
        [
          Product.new(id: 1, name: Faker::Commerce.product_name, price: 6000),
          Product.new(id: 2, name: Faker::Commerce.product_name, price: 8000)
        ]
      end

      it 'origin_amount is equal to products price sum' do
        expect(subject.origin_amount).to eq(14_000)
      end

      it 'discount amount should come from this promotion' do
        expect(subject.discount_amount).to eq(2000)
      end

      it 'result_amount should be' do
        expect(subject.result_amount).to eq(12_000)
      end

      it 'promotion quantity should be 0' do
        expect(promotions.first.quantity).to eq(0)
      end

      context 'when promotion quantity is 0, promotion is not applicable' do
        before { subject.perform }

        it 'discount_amount should be the same' do
          expect(subject.discount_amount).to eq(2000)
        end

        it 'result_amount should be the same' do
          expect(subject.result_amount).to eq(12_000)
        end

        it 'applied_promotions should not be increased' do
          expect(subject.applied_promotions.size).to eq(1)
        end
      end
    end

    describe 'when order is qualified to apply order over amount percent off max discount per person promotion' do
      let(:promotions) do
        [
          Promotion.new(id: 5, name: '訂單滿 3000 元可以折 10%，每人總共最高折 500 元', code: 'order_over_amount_percent_off_max_discount_per_person',
                        promotion_target_type: 'ORDER',
                        options: { over_amount: 3000, percent_off: 10, max_discount_amount: 2500 })
        ]
      end
      let(:product_a) { Product.new(id: 1, name: Faker::Commerce.product_name, price: 6000) }
      let(:product_b) { Product.new(id: 2, name: Faker::Commerce.product_name, price: 8000) }
      let(:products) { [product_a, product_b] }

      it 'origin_amount is equal to products price sum' do
        expect(subject.origin_amount).to eq(14_000)
      end

      it 'discount amount should come from this promotion' do
        expect(subject.discount_amount).to eq(1400)
      end

      it 'result_amount should be' do
        expect(subject.result_amount).to eq(12_600)
      end

      context 'when user with promotion logs over max discount amount 500' do
        let(:promotion_logs) do
          [
            PromotionLog.new(id: 1, user_id: 1, promotion_id: 5, discount_amount: 1300),
            PromotionLog.new(id: 2, user_id: 1, promotion_id: 5, discount_amount: 1200)
          ]
        end

        it 'promotion is not qualified of applying, discount amount should be zero' do
          expect(subject.discount_amount).to eq(0)
        end

        it 'there is no applied promotion ' do
          expect(subject.applied_promotions.size).to eq(0)
        end
      end
    end
  end
end
