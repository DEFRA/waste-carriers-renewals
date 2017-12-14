FactoryBot.define do
  factory :renewal_information_form do
    trait :has_required_data do
      initialize_with { new(create(:transient_registration, :has_required_data, workflow_state: "renewal_information_form")) }
    end
  end
end
