# Controller for Involved Civilians form.
class InvolvedCiviliansController < InvolvedPersonsController
  private

    def person_type
      :civilian
    end
end
