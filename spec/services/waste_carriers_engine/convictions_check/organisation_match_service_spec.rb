# frozen_string_literal: true

require "rails_helper"

module WasteCarriersEngine
  module ConvictionsCheck
    RSpec.describe OrganisationMatchService do
      describe "run" do
        let(:time) { Time.new(2019, 1, 1) }
        before { allow(Time).to receive(:current).and_return(time) }

        let(:name) { "foo" }
        let(:company_no) { "bar" }

        let(:entity_a) do
          double(:entity,
                 system_flag: "foo",
                 incident_number: "bar",
                 name: "baz")
        end
        let(:entity_b) do
          double(:entity,
                 system_flag: "qux",
                 incident_number: "quux",
                 name: "quuz")
        end

        subject do
          described_class.run(name: name,
                              company_no: company_no)
        end

        it "does not explode" do
          expect { subject }.to_not raise_error
        end

        it "checks for matching entities" do
          expect(Entity).to receive(:matching_organisations).with(name: name,
                                                                  company_no: company_no)
                                                            .and_return([entity_a])

          subject
        end

        context "when there are matches" do
          before { allow(Entity).to receive(:matching_organisations).and_return([entity_a, entity_b]) }

          it "returns a hash of data for the first entity" do
            data = {
              searched_at: time,
              confirmed: "no",
              confirmed_at: nil,
              confirmed_by: nil,
              match_result: "YES",
              matching_system: entity_a.system_flag,
              reference: entity_a.incident_number,
              matched_name: entity_a.name
            }

            expect(subject).to eq(data)
          end
        end

        context "when there are no matches" do
          before { allow(Entity).to receive(:matching_organisations).and_return([]) }

          it "returns a hash of data" do
            data = {
              searched_at: time,
              confirmed: "no",
              confirmed_at: nil,
              confirmed_by: nil,
              match_result: "NO"
            }

            expect(subject).to eq(data)
          end
        end

        context "when there is an error" do
          before { allow(Entity).to receive(:matching_organisations).and_raise(ArgumentError) }

          it "returns a hash of data" do
            data = {
              searched_at: time,
              confirmed: "no",
              confirmed_at: nil,
              confirmed_by: nil,
              match_result: "UNKNOWN",
              matching_system: "ERROR"
            }

            expect(subject).to eq(data)
          end
        end
      end
    end
  end
end