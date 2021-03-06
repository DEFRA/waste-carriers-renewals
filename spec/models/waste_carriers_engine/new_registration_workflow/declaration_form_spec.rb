# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe NewRegistration do
    subject { build(:new_registration, workflow_state: "declaration_form") }

    describe "#workflow_state" do
      context ":declaration_form state transitions" do
        context "on next" do
          context "when the registration is a lower tier" do
            subject { build(:new_registration, :lower, workflow_state: "declaration_form") }

            include_examples "has next transition", next_state: "registration_completed_form"
          end

          include_examples "has next transition", next_state: "cards_form"
        end

        context "on back" do
          include_examples "has back transition", previous_state: "check_your_answers_form"
        end
      end
    end
  end
end
