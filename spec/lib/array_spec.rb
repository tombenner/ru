require 'spec_helper'

describe Ru::Array do
  describe "Array method" do
    it "returns a Ru::Array" do
      array = described_class.new(%w{john paul george ringo})
      expect(array.sort).to be_a(Ru::Array)
    end
  end

  describe "#each_line" do
    it "calls to_s" do
      array = described_class.new((1..3).to_a)
      expect(array.each_line.to_s.to_a).to eq(described_class.new(('1'..'3')))
    end

    it "calls methods with arguments" do
      array = described_class.new((1..3).to_a)
      expect(array.each_line.modulo(2).to_a).to eq([1, 0, 1])
    end
  end

  describe "#map" do
    it "takes one argument" do
      array = described_class.new(%w{john paul george ringo})
      expect(array.map(:reverse)).to eq(%w{nhoj luap egroeg ognir})
    end
    it "takes two arguments" do
      array = described_class.new(%w{john paul george ringo})
      expect(array.map(:[], 0)).to eq(%w{j p g r})
    end

    it "returns a Ru::Array" do
      array = described_class.new(%w{john paul george ringo})
      expect(array.map(:[], 0)).to be_a(Ru::Array)
    end
  end
end
