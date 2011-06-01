# -*- encoding: utf-8 -*-
Dir[File.expand_path('support', File.dirname(__FILE__)) + "/**/*.rb"].each { |f| require f }

begin
  require 'simplecov'
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError
end

require 'stringio'
require 'terrible_things'