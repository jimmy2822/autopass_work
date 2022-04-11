# frozen_string_literal: true

require 'faker'
require_relative '../../models/product'

RSpec.describe Product, type: :model do
  describe 'Has columns' do
    subject { Product.new(id: id, name: name, price: price) }

    let(:id) { 1 }
    let(:name) { Faker::Commerce.product_name }
    let(:price) { Faker::Commerce.price }

    it 'has column id' do
      expect(subject.id).to eq(1)
    end

    it 'has column name' do
      expect(subject.name).to eq(name)
    end

    it 'has column price' do
      expect(subject.name).to eq(name)
    end
  end
end
