# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  RSpec.describe "ServiceProvidedForms", type: :request do
    include_examples "GET flexible form", "service_provided_form"

    describe "POST service_provided_form_path" do
      include_examples "POST renewal form",
                       "service_provided_form",
                       valid_params: { is_main_service: "yes" },
                       invalid_params: { is_main_service: "foo" },
                       test_attribute: :is_main_service

      context "When the transient_registration is a new registration" do
        let(:transient_registration) do
          create(:new_registration, workflow_state: "service_provided_form")
        end

        include_examples "POST form",
                         "service_provided_form",
                         valid_params: { is_main_service: "yes" },
                         invalid_params: { is_main_service: "foo" }
      end
    end

    describe "GET back_service_provided_forms_path" do
      context "when a valid user is signed in" do
        let(:user) { create(:user) }
        before(:each) do
          sign_in(user)
        end

        context "when a valid transient registration exists" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "service_provided_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the other_businesses form" do
              get back_service_provided_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_other_businesses_form_path(transient_registration[:token]))
            end
          end
        end

        context "when the transient registration is in the wrong state" do
          let(:transient_registration) do
            create(:renewing_registration,
                   :has_required_data,
                   account_email: user.email,
                   workflow_state: "renewal_start_form")
          end

          context "when the back action is triggered" do
            it "returns a 302 response and redirects to the correct form for the state" do
              get back_service_provided_forms_path(transient_registration[:token])

              expect(response).to have_http_status(302)
              expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:token]))
            end
          end
        end
      end
    end
  end
end
