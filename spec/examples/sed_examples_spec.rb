require 'spec_helper'

# https://www.gnu.org/software/sed/manual/sed.html#Examples
describe 'sed examples' do
  include FixturesHelper
  include ProcessHelper

  context "centering lines" do
    it "centers" do
      lines = %w{john paul george} + ['             ringo      ']
      out = run('each_line.strip.center(10)', lines)
      expect(out).to eq("   john   \n   paul   \n  george  \n  ringo   ")
    end
  end

  context "increment a number" do
    it "increments" do
      lines = ('5'..'10').to_a
      out = run('(each_line.to_i+1)', lines)
      expect(out).to eq(('6'..'11').to_a.join("\n"))
    end
  end

  context "reverse characters of lines" do
    it "reverses" do
      lines = %w{john paul george ringo}
      out = run('each_line.reverse', lines)
      expect(out).to eq("nhoj\nluap\negroeg\nognir")
    end
  end

  context "numbering lines" do
    it "numbers" do
      lines = %w{john paul george ringo}
      out = run('map.with_index { |line, index| "#{(index+1).to_s.rjust(6)}  #{line}" }', lines)
      expect(out).to eq("     1  john\n     2  paul\n     3  george\n     4  ringo")
    end
  end

  context "counting lines" do
    it "counts" do
      lines = %w{john paul george ringo}
      out = run('length', lines)
      expect(out).to eq("4")
    end
  end

  context "printing the first lines" do
    it "prints" do
      lines = %w{john paul george ringo}
      out = run('[0,2]', lines)
      expect(out).to eq("john\npaul")
    end
  end

  context "printing the last lines" do
    it "prints" do
      lines = %w{john paul george ringo}
      out = run('[2..-1]', lines)
      expect(out).to eq("george\nringo")
    end
  end

  context "make duplicate lines unique" do
    it "dedupes" do
      lines = %w{john john paul george george george ringo}
      out = run('uniq', lines)
      expect(out).to eq("john\npaul\ngeorge\nringo")
    end
  end

  context "print duplicated lines of input" do
    it "prints" do
      lines = %w{john john paul george george george ringo}
      out = run('select { |line| self.count(line) > 1 }', lines)
      expect(out).to eq("john\njohn\ngeorge\ngeorge\ngeorge")
    end
  end

  context "remove all duplicated lines" do
    it "removes" do
      lines = %w{john john paul george george george ringo}
      out = run('select { |line| self.count(line) == 1 }', lines)
      expect(out).to eq("paul\nringo")
    end
  end

  context "squeezing blank lines" do
    it "squeezes" do
      lines = "john\n\npaul\ngeorge\n\n\nringo"
      out = run('to_s.squeeze("\n")', lines)
      expect(out).to eq("john\npaul\ngeorge\nringo")
    end
  end
end
