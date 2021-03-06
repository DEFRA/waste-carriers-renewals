# frozen_string_literal: true

module WasteCarriersEngine
  class CannotRenewLowerTierFormsController < ::WasteCarriersEngine::FormsController
    include UnsubmittableForm

    def new
      super(CannotRenewLowerTierForm, "cannot_renew_lower_tier_form")
    end
  end
end
