# Models with this concern operate as a singleton. There should only ever be one
# record in the table. The global_unique_string field ensures this.
#
# Usage: Use self.instance() to access (find or create) the instance,
# and specify default fields to set (if any) in the self.DEFAULT_FIELDS hash.
module HasOnlyOneInstance
  extend ActiveSupport::Concern

  included do
    self.DEFAULT_FIELDS = {}
    self.GLOBAL_UNIQUE_STRING = 'specific-string-to-ensure-a-single-state'  # the actual string is irrelevant
    self.UNIQUENESS_ERROR_MESSAGE = "must set global_unique_string to '#{self.GLOBAL_UNIQUE_STRING}' (not '%{value}')"

    # Enforce that only one instance of this state ever exists.
    field :global_unique_string, :string
    validates :global_unique_string, uniqueness: true, inclusion: { in: [self.GLOBAL_UNIQUE_STRING],
                                                                    message: self.UNIQUENESS_ERROR_MESSAGE }

    # Set primary key.
    table key: :global_unique_string
  end

  # [Class methods.]
  module ClassMethods
    attr_accessor :DEFAULT_FIELDS, :GLOBAL_UNIQUE_STRING, :UNIQUENESS_ERROR_MESSAGE

    def instance
      # Get or create the singleton instance, being aware of concurrency issues
      find(self.GLOBAL_UNIQUE_STRING) || begin
        Rails.logger.info("Creating GlobalState singleton object")
        create(self.DEFAULT_FIELDS.merge(global_unique_string: self.GLOBAL_UNIQUE_STRING))
        # The above could fail if we race with another create attempt, but in
        # either case we can expect the state to be ready.
        find(self.GLOBAL_UNIQUE_STRING)
      end
    end
  end
end
