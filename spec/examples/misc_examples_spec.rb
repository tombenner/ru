require 'spec_helper'

describe 'misc examples' do
  include FixturesHelper
  include ProcessHelper

  # http://stackoverflow.com/questions/450799/shell-command-to-sum-integers-one-per-line
  context "summing integers" do
    it "sums" do
      lines = (1..10).to_a.map(&:to_s)
      out = run('map(:to_i).sum', lines)
      out.should == '55'
    end
  end

  # http://stackoverflow.com/questions/6022384/bash-tool-to-get-nth-line-from-a-file
  context "printing the nth line" do
    it "prints" do
      lines = (1..10).to_a.map(&:to_s)
      out = run('[4]', lines)
      out.should == '5'
    end
  end

  # https://coderwall.com/p/ueazhw
  context "sorting an Apache access log by response time" do
    it "sorts" do
      file = fixture_path('files', 'access.log')
      out = run(['map { |line| [line[/(\d+)( ".+"){2}$/, 1].to_i, line] }.sort.reverse.map(:join, " ")', file])
      out.should == <<-EOF.strip
584912 66.249.64.14 - - [18/Sep/2004:11:07:48 +1000] "GET /file.txt HTTP/1.0" 200 584912 "-" "Googlebot/2.1"
6433 66.249.64.14 - - [18/Sep/2004:11:07:48 +1000] "GET / HTTP/1.0" 200 6433 "-" "Googlebot/2.1"
6433 66.249.64.13 - - [18/Sep/2004:11:07:48 +1000] "GET / HTTP/1.0" 200 6433 "-" "Googlebot/2.1"
468 66.249.64.14 - - [18/Sep/2004:11:07:48 +1000] "GET /robots.txt HTTP/1.0" 200 468 "-" "Googlebot/2.1"
468 66.249.64.13 - - [18/Sep/2004:11:07:48 +1000] "GET /robots.txt HTTP/1.0" 200 468 "-" "Googlebot/2.1"
EOF
    end
  end
end
