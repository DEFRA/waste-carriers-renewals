# frozen_string_literal: true

module WasteCarriersEngine
  class CheckYourAnswersForm < BaseForm
    include CanDisplayDataOverview
    include CanLimitNumberOfMainPeople
    include CanLimitNumberOfRelevantPeople

    # This has to be before the validations are called, otherwise it fails.
    def self.custom_error_messages(attribute, *errors)
      messages = {}

      errors.each do |error|
        messages[error] = I18n.t("activemodel.errors.models."\
                                     "waste_carriers_engine/check_your_answers_form"\
                                     ".attributes.#{attribute}.#{error}")
      end

      messages
    end

    validates :business_type, "defra_ruby/validators/business_type": {
      allow_overseas: true,
      messages: custom_error_messages(:business_type, :inclusion)
    }
    validates :company_name, "waste_carriers_engine/company_name": true
    validates :company_no, "defra_ruby/validators/companies_house_number": true, if: :company_no_required?
    validates :contact_address, "waste_carriers_engine/address": true
    validates :contact_email, "defra_ruby/validators/email": {
      messages: custom_error_messages(:contact_email, :blank, :invalid_format)
    }
    validates :declared_convictions, "waste_carriers_engine/yes_no": true
    validates :first_name, :last_name, "waste_carriers_engine/person_name": true
    validates :location, "defra_ruby/validators/location": {
      allow_overseas: true,
      messages: custom_error_messages(:location, :inclusion)
    }
    validates :phone_number, "defra_ruby/validators/phone_number": true
    validates :registered_address, "waste_carriers_engine/address": true
    validates :registration_type, "waste_carriers_engine/registration_type": true
    validate :should_be_renewed

    validates_with KeyPeopleValidator

    after_initialize :valid

    def submit(_params)
      attributes = {}

      super(attributes)
    end

    def registration_type_changed?
      transient_registration.registration_type_changed?
    end

    def contact_name
      "#{first_name} #{last_name}"
    end

    private

    def valid
      valid?
    end

    def should_be_renewed
      business_type_change_valid? && same_company_no?
    end

    def business_type_change_valid?
      return true if transient_registration.business_type_change_valid?

      errors.add(:business_type, :invalid_change)
      false
    end

    def same_company_no?
      return true unless transient_registration.company_no_changed?

      errors.add(:company_no, :changed)
      false
    end

    def company_no_required?
      transient_registration.company_no_required?
    end
  end
end
