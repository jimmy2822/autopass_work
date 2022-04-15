# frozen_string_literal: true

require 'faker'
require_relative '../../services/calculation_service'
require_relative '../../models/product'

RSpec.describe CalculationService do
  subject { CalculationService.new(products: products, promotions: promotions) }

  describe '#perform' do
    before { subject.perform }

    let(:promotions) do
      [
        Promotion.new(id: 1, name: '特定商品滿 2 件折 100 元', code: 'multiple_products_promotion',
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
      let(:product_a) { Product.new(id: 1, name: Faker::Commerce.product_name, price: 200) }
      let(:product_b) { Product.new(id: 2, name: Faker::Commerce.product_name, price: 300) }
      let(:products) { [product_a, product_b] }

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
      let(:product_a) { Product.new(id: 1, name: Faker::Commerce.product_name, price: 300) }
      let(:product_b) { Product.new(id: 1, name: Faker::Commerce.product_name, price: 300) }
      let(:products) { [product_a, product_b] }

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
      let(:product_a) { Product.new(id: 1, name: Faker::Commerce.product_name, price: 500) }
      let(:product_b) { Product.new(id: 2, name: Faker::Commerce.product_name, price: 500) }
      let(:products) { [product_a, product_b] }

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
      let(:product_a) { Product.new(id: 1, name: Faker::Commerce.product_name, price: 1000) }
      let(:product_b) { Product.new(id: 2, name: Faker::Commerce.product_name, price: 2000) }
      let(:products) { [product_a, product_b] }

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
      let(:product_a) { Product.new(id: 1, name: Faker::Commerce.product_name, price: 6000) }
      let(:product_b) { Product.new(id: 2, name: Faker::Commerce.product_name, price: 8000) }
      let(:products) { [product_a, product_b] }

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
  end
end
