# Base class for queries. Subclasses must implement #perform_query.
class Query
  def run(params)
    # Request-level memoization.
    key = params.merge(query: self.class.name).to_s
    result = RequestStore.store[key] ||= perform_query(params)
    result.clone  # (Just in case another query tries to mutate the result.)
  end

  private

    def perform_query
      raise UnimplementedError.new
    end
end
