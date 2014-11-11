require 'active_support/all'

directory = File.dirname(File.absolute_path(__FILE__))
Dir.glob("#{directory}/rushed/*.rb") { |file| require file }

module Rushed
end
