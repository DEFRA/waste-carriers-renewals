# frozen_string_literal: true

module WasteCarriersEngine
  class CopyCardsPaymentFormsController < BaseOrderCopyCardsFormsController
    def new
      super(CopyCardsPaymentForm, "copy_cards_payment_form")
    end

    def create
      super(CopyCardsPaymentForm, "copy_cards_payment_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:copy_cards_payment_form, {}).permit(:temp_payment_method)
    end
  end
end