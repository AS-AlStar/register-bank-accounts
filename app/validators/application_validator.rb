# frozen_string_literal: true

class ApplicationValidator
  include Virtus.model
  include ActiveModel::Validations

  Result = Struct.new(:data, :success?)

  def self.call(attrs)
    object = new(attrs)
    if object.valid?
      Result.new(object.attributes, true)
    else
      Result.new(object.errors.messages, false)
    end
  end

  def currency_code
    return if errors[:currency].any?

    Money::Currency.new(currency)
  rescue Money::Currency::UnknownCurrency
    errors.add :currency, 'Unknown currency or invalid format'
  end
end
