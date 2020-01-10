# frozen_string_literal: true

module WasteCarriersEngine
  class PostcodeFormsController < FormsController
    def skip_to_manual_address
      find_or_initialize_transient_registration(params[:_id])

      @transient_registration.skip_to_manual_address! if form_matches_state?
      redirect_to_correct_form
    end
  end
end
