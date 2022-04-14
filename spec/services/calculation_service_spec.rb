# frozen_string_literal: true

require 'faker'
require_relative '../../services/calculation_service'
require_relative '../../models/product'

RSpec.describe CalculationService do
  subject { CalculationService.new(products: products) }

  describe '#perform' do
    before { subject.perform }

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

      it 'discount amount should be 0' do
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
  end
end
