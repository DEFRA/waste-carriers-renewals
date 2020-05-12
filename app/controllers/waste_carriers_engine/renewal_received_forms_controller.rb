# frozen_string_literal: true

module WasteCarriersEngine
  class RenewalReceivedFormsController < FormsController
    include UnsubmittableForm
    include CannotGoBackForm

    helper JourneyLinksHelper

    def new
      super(RenewalReceivedForm, "renewal_received_form")
    end
  end
end
