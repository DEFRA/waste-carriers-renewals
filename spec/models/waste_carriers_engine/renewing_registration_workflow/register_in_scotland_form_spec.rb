# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe RenewingRegistration, type: :model do
    describe "#workflow_state" do
      context "when a RenewingRegistration's state is :register_in_scotland_form" do
        let(:transient_registration) do
          create(:renewing_registration,
                 :has_required_data,
                 workflow_state: "register_in_scotland_form")
        end

        it "changes to :location_form after the 'back' event" do
          expect(transient_registration).to transition_from(:register_in_scotland_form).to(:location_form).on_event(:back)
        end

        it "changes to :business_type_form after the 'next' event" do
          expect(transient_registration).to transition_from(:register_in_scotland_form).to(:business_type_form).on_event(:next)
        end
      end
    end
  end
end