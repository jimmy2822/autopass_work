# frozen_string_literal: true

class User
  attr_accessor :id, :name

  def initialize(id:, name:)
    @id = id
    @name = name
  end
end
