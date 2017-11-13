FactoryBot.define do
  factory :registration do
    trait :has_required_data do
      regIdentifier "CBDU1"
    end

    trait :has_required_relations do
      metaData { build(:metaData) }
      addresses { [build(:address)] }
    end

    trait :has_expiresOn do
      expiresOn 2.years.from_now
    end

    trait :is_pending do
      metaData { build(:metaData, status: :pending) }
    end

    trait :is_active do
      metaData { build(:metaData, status: :active) }
    end

    trait :is_revoked do
      metaData { build(:metaData, status: :revoked) }
    end

    trait :is_refused do
      metaData { build(:metaData, status: :refused) }
    end

    trait :is_expired do
      metaData { build(:metaData, status: :expired) }
    end
  end
end
