FactoryBot.define do
  factory :transient_registration do
    trait :has_required_data do
      location "england"
      declared_convictions "false"
      temp_cards 1

      # Create a new registration when initializing so we can copy its data
      initialize_with { new(reg_identifier: create(:registration, :has_required_data, :expires_soon).reg_identifier) }
    end

    trait :has_addresses do
      addresses { [build(:address, :has_required_data, :registered, :from_os_places), build(:address, :has_required_data, :contact, :from_os_places)] }
    end

    trait :has_key_people do
      keyPeople do
        [build(:key_person, :has_required_data, :main),
         build(:key_person, :has_required_data, :relevant)]
      end
    end

    trait :has_postcode do
      temp_company_postcode "BS1 5AH"
      temp_contact_postcode "BS1 5AH"
    end

    trait :declared_convictions do
      declared_convictions "true"
    end

    trait :has_finance_details do
      after(:build, :create) do |transient_registration|
        FinanceDetails.new_finance_details(transient_registration)
      end
    end

    # Overseas registrations

    trait :has_required_overseas_data do
      location "overseas"
      declared_convictions "false"
      temp_cards 1

      # Create a new registration when initializing so we can copy its data
      initialize_with { new(reg_identifier: create(:registration, :has_required_overseas_data, :expires_soon).reg_identifier) }
    end

    trait :has_overseas_addresses do
      addresses do
        [build(:address, :has_required_data, :registered, :manual_foreign),
         build(:address, :has_required_data, :contact, :manual_foreign)]
      end
    end

    trait :has_matching_convictions do
      company_name "Test Waste Services Ltd."
      company_no "12345678"

      keyPeople do
        [build(:key_person, :has_matching_conviction, :main)]
      end
    end
  end
end
