# frozen_string_literal: true

require 'faker'
require_relative '../../models/user'

RSpec.describe User, type: :model do
  describe 'Has columns' do
    subject { User.new(id: id, name: name) }

    let(:id) { 1 }
    let(:name) { Faker::Name.name }

    it 'has column id' do
      expect(subject.id).to eq(1)
    end

    it 'has column name' do
      expect(subject.name).to eq(name)
    end
  end
end
