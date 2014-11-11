require 'spec_helper'

describe Rushed::Process do
  include FixturesHelper
  include ProcessHelper

  describe "#run" do
    it "runs []" do
      lines = %w{john paul george ringo}
      out = run(lines, '[1,2]')
      out.should == "paul\ngeorge"
    end

    it "runs files" do
      paths = [
        fixture_path('files', 'bar.txt'),
        fixture_path('files', 'foo.txt')
      ]
      out = run(paths, 'files')
      out.should == "bar.txt\nfoo.txt"
    end

    it "runs format" do
      paths = [
        fixture_path('files', 'bar.txt'),
        fixture_path('files', 'foo.txt')
      ]
      out = run(paths, "files.format('l')")
      lines = out.split("\n")
      lines.length.should == 2
      lines.each do |line|
        # 644 tom staff 11  2014-11-04  08:29 foo.txt
        line.should =~ /^\d{3}\t\w+\t\w+\t\d+\t\d{4}\-\d{2}-\d{2}\t\d{2}:\d{2}\t[\w\.]+$/
      end
    end

    it "runs grep" do
      lines = %w{john paul george ringo}
      out = run(lines, "grep(/o[h|r]/)")
      out.should == "john\ngeorge"
    end

    it "runs map with two arguments" do
      lines = %w{john paul george ringo}
      out = run(lines, 'map(:[], 0)')
      out.should == %w{j p g r}.join("\n")
    end

    it "runs sort" do
      lines = %w{john paul george ringo}
      out = run(lines, 'sort')
      out.should == lines.sort.join("\n")
    end

    it "takes files as arguments" do
      out = run('', 'to_s', fixture_path('files', 'foo.txt'))
      out.should == "foo\nfoo\nfoo"
    end

    context "an undefined method" do
      it "raises a NoMethodError" do
        lines = %w{john paul george ringo}
        expect { out = run(lines, 'foo') }.to raise_error(NoMethodError)
      end
    end
  end
end
