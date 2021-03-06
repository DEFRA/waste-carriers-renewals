# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe EditRegistration do
    subject { build(:edit_registration, workflow_state: "main_people_form") }

    describe "#workflow_state" do
      context ":main_people_form state transitions" do
        context "on next" do
          include_examples "has next transition", next_state: "edit_form"
        end

        context "on back" do
          include_examples "has back transition", previous_state: "edit_form"
        end
      end
    end
  end
end
