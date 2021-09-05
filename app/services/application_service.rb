# frozen_string_literal: true

class ApplicationService
  class FailureError < StandardError
    attr_reader :data

    def initialize(data = {})
      @data = data
      super('failure')
    end
  end
  Result = Struct.new(:data, :success?)

  def test; end

  def call(**context)
    context = self.class.steps.inject(context) do |ctx, step|
      send(step, **ctx)
    end
    Result.new(context, true)
  rescue FailureError => e
    Result.new(e.data, false)
  end

  def initialize(**dependencies)
    self.class.dependencies.merge(dependencies).each do |key, value|
      instance_variable_set "@#{key}", value
    end
  end

  class << self
    def steps
      @steps ||= []
    end

    def dependency(key, object)
      dependencies[key] = object

      define_method key do
        instance_variable_get "@#{key}"
      end
    end

    def dependencies
      @dependencies ||= {}
    end

    def step(method_name)
      steps << method_name
    end
  end
end
