require "rails_helper"
require "support/shared_examples/request_get_locked_in_form"

RSpec.describe "CheckYourAnswersForms", type: :request do
  include_examples "GET locked-in form", form = "check_your_answers_form"

  describe "POST check_your_answers_forms_path" do
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
                 workflow_state: "check_your_answers_form")
        end

        context "when valid params are submitted" do
          let(:valid_params) {
            {
              reg_identifier: transient_registration[:reg_identifier]
            }
          }

          it "updates the transient registration" do
            # TODO: Add test once data is submitted through the form
          end

          it "returns a 302 response" do
            post check_your_answers_forms_path, check_your_answers_form: valid_params
            expect(response).to have_http_status(302)
          end

          it "redirects to the declaration form" do
            post check_your_answers_forms_path, check_your_answers_form: valid_params
            expect(response).to redirect_to(new_declaration_form_path(transient_registration[:reg_identifier]))
          end
        end

        context "when invalid params are submitted" do
          let(:invalid_params) {
            {
              reg_identifier: "foo"
            }
          }

          it "returns a 302 response" do
            post check_your_answers_forms_path, check_your_answers_form: invalid_params
            expect(response).to have_http_status(302)
          end

          it "does not update the transient registration" do
            post check_your_answers_forms_path, check_your_answers_form: invalid_params
            expect(transient_registration.reload[:reg_identifier]).to_not eq(invalid_params[:reg_identifier])
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
            reg_identifier: transient_registration[:reg_identifier]
          }
        }

        it "does not update the transient registration" do
          # TODO: Add test once data is submitted through the form
        end

        it "returns a 302 response" do
          post check_your_answers_forms_path, check_your_answers_form: valid_params
          expect(response).to have_http_status(302)
        end

        it "redirects to the correct form for the state" do
          post check_your_answers_forms_path, check_your_answers_form: valid_params
          expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
        end
      end
    end
  end

  describe "GET back_check_your_answers_forms_path" do
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
                 workflow_state: "check_your_answers_form")
        end

        context "when the back action is triggered" do
          it "returns a 302 response" do
            get back_check_your_answers_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the contact_address form" do
            get back_check_your_answers_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_contact_address_form_path(transient_registration[:reg_identifier]))
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
            get back_check_your_answers_forms_path(transient_registration[:reg_identifier])
            expect(response).to have_http_status(302)
          end

          it "redirects to the correct form for the state" do
            get back_check_your_answers_forms_path(transient_registration[:reg_identifier])
            expect(response).to redirect_to(new_renewal_start_form_path(transient_registration[:reg_identifier]))
          end
        end
      end
    end
  end
end
