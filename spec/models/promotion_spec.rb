# frozen_string_literal: true

require 'faker'
require_relative '../../models/promotion'

RSpec.describe Promotion, type: :model do
  describe 'Has columns' do
    subject do
      Promotion.new(id: id, name: name, code: code,
                    promotion_target_type: promotion_target_type,
                    quantity: quantity, options: options)
    end

    let(:id) { 1 }
    let(:name) { Faker::Commerce.product_name }
    let(:code) { Faker::Code.isbn }
    let(:promotion_target_type) { Faker::Beer.name }
    let(:quantity) { 1 }
    let(:options) { { x: 1 } }

    it 'has column id' do
      expect(subject.id).to eq(1)
    end

    it 'has column name' do
      expect(subject.name).to eq(name)
    end

    it 'has column code' do
      expect(subject.code).to eq(code)
    end

    it 'has column quantity' do
      expect(subject.quantity).to eq(1)
    end

    it 'has column options' do
      expect(subject.options[:x]).to eq(1)
    end
  end
end
