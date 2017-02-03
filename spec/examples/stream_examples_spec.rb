require 'spec_helper'

describe 'stream examples' do
  include FixturesHelper
  include ProcessHelper

  context 'misc stream examples' do
    # http://stackoverflow.com/questions/450799/shell-command-to-sum-integers-one-per-line
    context "summing integers" do
      it "sums" do
        lines = (1..10).to_a.map(&:to_s)
        out   = run_stream('map(:to_i).sum', lines)
        expect(out).to eq('55')
      end
    end

    # http://stackoverflow.com/questions/6022384/bash-tool-to-get-nth-line-from-a-file
    context "printing the nth line" do
      it "prints" do
        lines = (1..10).to_a.map(&:to_s)
        out   = run_stream('[4]', lines)
        expect(out).to eq('5')
      end
    end

    # https://coderwall.com/p/ueazhw
    context "sorting an Apache access log by response time" do
      it "sorts" do
        file = fixture_path('files', 'access.log')
        out  = run_stream(['map { |line| [line[/(\d+)( ".+"){2}$/, 1].to_i, line] }.sort.reverse.map(:join, " ")', file])
        expect(out).to eq(<<-EOF.strip
584912 66.249.64.14 - - [18/Sep/2004:11:07:48 +1000] "GET /file.txt HTTP/1.0" 200 584912 "-" "Googlebot/2.1"
6433 66.249.64.14 - - [18/Sep/2004:11:07:48 +1000] "GET / HTTP/1.0" 200 6433 "-" "Googlebot/2.1"
6433 66.249.64.13 - - [18/Sep/2004:11:07:48 +1000] "GET / HTTP/1.0" 200 6433 "-" "Googlebot/2.1"
468 66.249.64.14 - - [18/Sep/2004:11:07:48 +1000] "GET /robots.txt HTTP/1.0" 200 468 "-" "Googlebot/2.1"
468 66.249.64.13 - - [18/Sep/2004:11:07:48 +1000] "GET /robots.txt HTTP/1.0" 200 468 "-" "Googlebot/2.1"
                       EOF
                       )
      end
    end
  end

  # https://www.gnu.org/software/sed/manual/sed.html#Examples
  context 'sed stream examples' do
    include FixturesHelper
    include ProcessHelper

    context "centering lines" do
      it "centers" do
        lines = %w{john paul george} + ['             ringo      ']
        out   = run_stream('each_line.strip.center(10)', lines)
        expect(out).to eq("   john   \n   paul   \n  george  \n  ringo   ")
      end
    end

    context "increment a number" do
      it "increments" do
        lines = ('5'..'10').to_a
        out   = run_stream('(each_line.to_i+1)', lines)
        expect(out).to eq(('6'..'11').to_a.join("\n"))
      end
    end

    context "reverse characters of lines" do
      it "reverses" do
        lines = %w{john paul george ringo}
        out   = run_stream('each_line.reverse', lines)
        expect(out).to eq("nhoj\nluap\negroeg\nognir")
      end
    end

    context "numbering lines" do
      it "numbers" do
        lines = %w{john paul george ringo}
        out   = run_stream('each_with_index.map { |line, index| "#{(index+1).to_s.rjust(6)}  #{line}" }', lines)
        expect(out).to eq("     1  john\n     2  paul\n     3  george\n     4  ringo")
      end
    end

    context "counting lines" do
      it "counts" do
        lines = %w{john paul george ringo}
        out   = run_stream('length', lines)
        expect(out).to eq("4")
      end
    end

    context "printing the first lines" do
      it "prints" do
        lines = %w{john paul george ringo}
        out   = run_stream('[0,2]', lines)
        expect(out).to eq("john\npaul")
      end
    end

    context "printing the last lines" do
      it "prints" do
        lines = %w{john paul george ringo}
        out   = run_stream('[2..-1]', lines)
        expect(out).to eq("george\nringo")
      end
    end

    context "make duplicate lines unique" do
      it "dedupes" do
        lines = %w{john john paul george george george ringo}
        out   = run_stream('uniq', lines)
        expect(out).to eq("john\npaul\ngeorge\nringo")
      end
    end

    context "print duplicated lines of input" do
      it "prints" do
        lines = %w{john john paul george george george ringo}
        out   = run_stream('select { |line| self.count(line) > 1 }', lines)
        expect(out).to eq("john\njohn\ngeorge\ngeorge\ngeorge")
      end
    end

    context "remove all duplicated lines" do
      it "removes" do
        lines = %w{john john paul george george george ringo}
        out   = run_stream('select { |line| self.count(line) == 1 }', lines)
        expect(out).to eq("paul\nringo")
      end
    end

    context "squeezing blank lines" do
      it "squeezes" do
        lines = "john\n\npaul\ngeorge\n\n\nringo"
        out   = run_stream('to_s.squeeze("\n")', lines)
        expect(out).to eq("john\npaul\ngeorge\nringo")
      end
    end
  end
end
