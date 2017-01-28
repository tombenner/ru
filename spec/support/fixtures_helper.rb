require 'pathname'

module FixturesHelper
  def fixture_path(*args)
    directory = Pathname.new(File.dirname(File.absolute_path(__FILE__)))
    directory.join('..', 'fixtures', *args).to_s
  end
end