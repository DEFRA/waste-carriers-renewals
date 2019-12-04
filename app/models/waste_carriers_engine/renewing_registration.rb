# frozen_string_literal: true

module WasteCarriersEngine
  class RenewingRegistration < TransientRegistration
    include CanUseRenewingRegistrationWorkflow

    validate :no_renewal_in_progress?, on: :create
    validates :reg_identifier, "waste_carriers_engine/reg_identifier": true

    after_initialize :copy_data_from_registration

    # Check if the user has changed the registration type, as this incurs an additional 40GBP charge
    def registration_type_changed?
      # Don't compare registration types if the new one hasn't been set
      return false unless registration_type

      registration.registration_type != registration_type
    end

    def registration
      @_registration ||= Registration.find_by(reg_identifier: reg_identifier)
    end

    def fee_including_possible_type_change
      if registration_type_changed?
        Rails.configuration.renewal_charge + Rails.configuration.type_change_charge
      else
        Rails.configuration.renewal_charge
      end
    end

    def projected_renewal_end_date
      return unless expires_on.present?

      ExpiryCheckService.new(self).expiry_date_after_renewal
    end

    def pending_payment?
      renewal_application_submitted? && super
    end

    def prepare_for_payment(mode, user)
      FinanceDetails.new_renewal_finance_details(self, mode, user)
    end

    def company_no_changed?
      return false unless company_no_required?

      # LLP is a new business type, so users who previously were forced to select 'partnership' would not have had the
      # opportunity to enter a company_no. Therefore we have nothing to compare against and should allow users to
      # continue the renewal journey.
      return false if registration.business_type == "partnership"

      # It was previously possible to save a company_no with excess whitespace. This is no longer possible, but we
      # should ignore this whitespace when comparing, otherwise a trailing space will block the user from renewing their
      # registration.
      old_company_no = registration.company_no.to_s.strip

      # It was previously valid to have company_nos with less than 8 digits
      # The form prepends 0s to make up the length, so we should do this for the old number to match
      old_company_no = "0#{old_company_no}" while old_company_no.length < 8
      old_company_no != company_no
    end

    def renewal_application_submitted?
      not_in_progress_states = %w[renewal_received_form renewal_complete_form]
      not_in_progress_states.include?(workflow_state)
    end

    def can_be_renewed?
      return false unless %w[ACTIVE EXPIRED].include?(metaData.status)

      # The only time an expired registration can be renewed is if the
      # application
      # - has a confirmed declaration i.e. user reached the copy cards page
      # - it is within the grace window
      return true if declaration_confirmed?

      check_service = ExpiryCheckService.new(self)
      return true if check_service.in_expiry_grace_window?
      return false if check_service.expired?

      check_service.in_renewal_window?
    end

    def ready_to_complete?
      # Though both pending_payment? and pending_manual_conviction_check? also
      # check that the renewal has been submitted, if it hasn't they would both
      # return false, which would mean we would not stop the renewal from
      # completing. Hence we have to check it separately first
      return false unless renewal_application_submitted?
      return false if pending_payment?
      return false if pending_manual_conviction_check?

      true
    end

    def stuck?
      return false unless renewal_application_submitted?
      return true if conviction_sign_offs&.first&.rejected?
      return false if pending_payment? || pending_manual_conviction_check?

      true
    end

    def pending_manual_conviction_check?
      renewal_application_submitted? && super
    end

    private

    # Check if a transient renewal already exists for this registration so we don't have
    # multiple renewals in progress at once
    def no_renewal_in_progress?
      return unless RenewingRegistration.where(reg_identifier: reg_identifier).exists?

      errors.add(:reg_identifier, :renewal_in_progress)
    end

    def copy_data_from_registration
      # Don't try to get Registration data with an invalid reg_identifier
      return unless valid? && new_record?

      # Don't copy object IDs as Mongo should generate new unique ones
      # Don't copy smart answers as we want users to use the latest version of the questions
      attributes = registration.attributes.except("_id",
                                                  "otherBusinesses",
                                                  "isMainService",
                                                  "constructionWaste",
                                                  "onlyAMF",
                                                  "addresses",
                                                  "key_people",
                                                  "financeDetails",
                                                  "declaredConvictions",
                                                  "conviction_search_result",
                                                  "conviction_sign_offs",
                                                  "declaration",
                                                  "past_registrations",
                                                  "copy_cards")

      assign_attributes(strip_whitespace(attributes))
      remove_invalid_attributes
    end

    def remove_invalid_attributes
      remove_invalid_phone_numbers
      remove_revoked_reason
    end

    def remove_invalid_phone_numbers
      validator = DefraRuby::Validators::PhoneNumberValidator.new(attributes: :phone_number)
      return if validator.validate_each(self, :phone_number, phone_number)

      self.phone_number = nil
    end

    def remove_revoked_reason
      metaData.revoked_reason = nil
    end
  end
end
