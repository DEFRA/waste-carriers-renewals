# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    subject do
      build(:renewing_registration,
            :has_required_data,
            workflow_state: "check_your_answers_form")
    end

    describe "#workflow_state" do
      context ":check_your_answers_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "declaration_form"
        end

        context "on back" do
          include_examples "has back transition", previous_state: "contact_address_form"
        end
      end
    end
  end
end
