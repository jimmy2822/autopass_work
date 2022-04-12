# frozen_string_literal: true

require 'faker'
require_relative '../../services/calculation_service'
require_relative '../../models/product'

RSpec.describe CalculationService do
  describe 'Has columns' do
    subject { CalculationService.new(products: products) }

    describe '#perform' do
      before { subject.perform }

      let(:product_a) { Product.new(id: 1, name: Faker::Commerce.product_name, price: 1000) }
      let(:product_b) { Product.new(id: 2, name: Faker::Commerce.product_name, price: 300) }
      let(:product_c) { Product.new(id: 3, name: Faker::Commerce.product_name, price: 500) }
      let(:product_d) { Product.new(id: 2, name: Faker::Commerce.product_name, price: 300) }
      let(:products) { [product_a, product_b, product_c, product_d] }

      it 'origin_amount is equal to products price sum' do
        expect(subject.origin_amount).to eq(2100)
      end

      it 'discount_amount is equal to multiple_products_promotion' do
        expect(subject.discount_amount).to eq(100)
      end

      it 'result_amount should be' do
        expect(subject.result_amount).to eq(2000)
      end
    end
  end
end
