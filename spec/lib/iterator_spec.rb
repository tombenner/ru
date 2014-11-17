require 'spec_helper'

describe Ru::Iterator do
  describe "#to_a" do
    it "returns the array" do
      iterator = described_class.new(%w{john paul george ringo})
      expect(iterator.to_a).to eq(%w{john paul george ringo})
    end
  end
  
  describe "#to_dotsch_output" do
    it "returns the string" do
      iterator = described_class.new(%w{john paul george ringo})
      expect(iterator.to_dotsch_output).to eq("john\npaul\ngeorge\nringo")
    end

    context "with a method called on it" do
      it "returns the string" do
        iterator = described_class.new(%w{john paul george ringo})
        expect(iterator.to_s.to_dotsch_output).to eq("john\npaul\ngeorge\nringo")
      end
    end
  end
end
