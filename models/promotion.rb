# frozen_string_literal: true

class Promotion
  attr_accessor :id, :name, :code, :type

  def initialize(id:, name:, code:, type:)
    @id = id
    @name = name
    @code = code
    @type = type
  end
end
