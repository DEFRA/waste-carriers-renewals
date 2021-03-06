# frozen_string_literal: true

module WasteCarriersEngine
  class CardsFormsController < ::WasteCarriersEngine::FormsController
    def new
      super(CardsForm, "cards_form")
    end

    def create
      super(CardsForm, "cards_form")
    end

    private

    def transient_registration_attributes
      params.fetch(:cards_form, {}).permit(:temp_cards)
    end
  end
end
