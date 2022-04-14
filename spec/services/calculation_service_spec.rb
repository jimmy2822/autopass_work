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

    describe 'when products are qualified to apply multiple product discount promotion' do
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
  end
end
