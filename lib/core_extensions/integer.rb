# Monkey-patches to the Integer class go here.
class Integer
  # Run a block a given number of times, sleeping and retrying when
  # an exception of the given type is caught.
  def tries(catching: StandardError)
    retries ||= 0
    yield
  rescue catching
    if (retries += 1) <= self
      sleep 1 << retries  # (Sleep with exponential backoff.)
      retry
    end
    raise
  end
end
