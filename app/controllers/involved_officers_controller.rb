# Controller for Involved Officers form.
class InvolvedOfficersController < InvolvedPersonsController
  private

    def person_type
      :officer
    end
end
