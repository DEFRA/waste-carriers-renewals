# frozen_string_literal: true

module WasteCarriersEngine
  class CopyCardsOrderCompletedFormsController < FormsController
    include UnsubmittableForm

    def new
      return unless super(CopyCardsOrderCompletedForm, "copy_cards_order_completed_form")

      OrderCopyCardsCompletionService.run(@transient_registration)
    end

    def go_back; end
  end
end
