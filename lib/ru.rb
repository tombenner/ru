require 'active_support/all'

directory = File.dirname(File.absolute_path(__FILE__))
Dir.glob("#{directory}/ru/*.rb") { |file| require file }

module Ru
end
