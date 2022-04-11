# frozen_string_literal: true

require 'faker'
require_relative '../../models/promotion'

RSpec.describe Promotion, type: :model do
  describe 'Has columns' do
    subject { Promotion.new(id: id, name: name, code: code, type: type) }

    let(:id) { 1 }
    let(:name) { Faker::Commerce.product_name }
    let(:code) { Faker::Code.isbn }
    let(:type) { Faker::Beer.name }

    it 'has column id' do
      expect(subject.id).to eq(1)
    end

    it 'has column name' do
      expect(subject.name).to eq(name)
    end

    it 'has column code' do
      expect(subject.code).to eq(code)
    end

    it 'has column type' do
      expect(subject.type).to eq(type)
    end
  end
end
