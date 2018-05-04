require "rails_helper"
require "support/shared_examples/request_get_locked_in_form"

RSpec.describe "PaymentSummaryForms", type: :request do
  include_examples "GET locked-in form", form = "payment_summary_form"

  describe "POST payment_summary_forms_path" do
    context "when a valid user is signed in" do
      let(:user) { create(:user) }
      before(:each) do
        sign_in(user)
      end

      context "when a valid transient registration exists" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 account_email: user.email,
                 workflow_state: "payment_summary_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier],
              temp_payment_method: "card"
            }
          }

          it "updates the transient registration" do
            post payment_summary_forms_path, payment_summary_form: valid_params
            expect(transient_registration.reload[:temp_payment_method]).to eq(valid_params[:temp_payment_method])
          end

          it "returns a 302 response" do
            post payment_summary_forms_path, payment_summary_form: valid_params
            expect(response).to have_http_status(302)
          end

          context "when the payment method is card" do
            it "redirects to the worldpay form" do
              post payment_summary_forms_path, payment_summary_form: valid_params
              expect(response).to redirect_to(new_worldpay_form_path(transient_registration[:reg_identifier]))
            end
          end

          context "when the payment method is bank transfer" do
            before(:each) { valid_params[:temp_payment_method] = "bank_transfer" }

            it "redirects to the bank_transfer form" do
              post payment_summary_forms_path, payment_summary_form: valid_params
              expect(response).to redirect_to(new_bank_transfer_form_path(transient_registration[:reg_identifier]))
            end
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              reg_identifier: "foo",
              temp_payment_method: "foo"
            }
          }

          it "returns a 302 response" do
            post payment_summary_forms_path, payment_summary_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post payment_summary_forms_path, payment_summary_form: invalid_params
            expect(transient_registration.reload[:temp_payment_method]).to_not eq(invalid_params[:temp_payment_method])
          end
        end
      end

      context "when the transient registration is in the wrong state" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 account_email: user.email,
                 workflow_state: "renewal_start_form")
        end

        let(:valid_params) {
          {
            reg_identifier: transient_registration[:reg_identifier],
            temp_payment_method: "card"
          }
        }

        it "does not update the transient registration" do
          post payment_summary_forms_path, payment_summary_form: valid_params
          expect(transient_registration.reload[:temp_payment_method]).to_not eq(valid_params[:temp_payment_method])
        end

        it "returns a 302 response" do
          post payment_summary_forms_path, payment_summary_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post payment_summary_forms_path, payment_summary_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_payment_summary_forms_path" do
    context "when a valid user is signed in" do
      let(:user) { create(:user) }
      before(:each) do
        sign_in(user)
      end

      context "when a valid transient registration exists" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 account_email: user.email,
                 workflow_state: "payment_summary_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_payment_summary_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the cards form" do
            get back_payment_summary_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_cards_form_path(transient_registration[:reg_identifier]))
          end
        end
      end

      context "when the transient registration is in the wrong state" do
        let(:transient_registration) do
          create(:transient_registration,
                 :has_required_data,
                 account_email: user.email,
                 workflow_state: "renewal_start_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_payment_summary_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_payment_summary_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
