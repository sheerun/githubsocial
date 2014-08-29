class Metrics
  def increment(*args)
    Librato.increment(*args)
  end

  def measure(*args, &block)
    Librato.measure(*args, &block)
  end
end
