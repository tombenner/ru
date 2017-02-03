require 'spec_helper'

require 'spec_helper'

describe Ru::Stream do
  describe "Array method" do
    it "returns a Ru::Array" do
      array = described_class.new(%w{john paul george ringo}.each.lazy)
      expect(array.to_a.sort).to be_a(Ru::Array)
    end
  end

  describe "#each_line" do
    it "calls to_s" do
      array = described_class.new((1..3).each.lazy)
      expect(array.each_line.to_s).to be_a(described_class)
      expect(array.each_line.to_s.to_a).to eq(Ru::Array.new('1'..'3'))
    end

    it "calls methods with arguments" do
      array = described_class.new((1..3).each.lazy)
      expect(array.each_line.modulo(2).to_a).to eq([1, 0, 1])
    end
  end

  describe "#map" do
    it "takes one argument" do
      array = described_class.new(%w{john paul george ringo}.each.lazy)
      expect(array.map(:reverse).to_a).to eq(%w{nhoj luap egroeg ognir})
    end
    it "takes two arguments" do
      array = described_class.new(%w{john paul george ringo}.each.lazy)
      expect(array.map(:[], 0).to_a).to eq(%w{j p g r})
    end

    it "returns a Ru::Stream" do
      array = described_class.new(%w{john paul george ringo}.each.lazy)
      expect(array.map(:[], 0)).to be_a(Ru::Stream)
    end
  end
end
