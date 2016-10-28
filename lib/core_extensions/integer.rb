# Monkey-patches to the Integer class go here.
class Integer
  # Allows ActionView::Helpers::TextHelper#pluralize to be used outside of views.
  def pluralize(word)
    ActionController::Base.helpers.pluralize(self, word)
  end

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
