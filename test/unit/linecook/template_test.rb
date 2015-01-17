#!/usr/bin/env ruby
require File.expand_path('../../helper', __FILE__)
require 'linecook/template'

class Linecook::TemplateTest < Test::Unit::TestCase
  Template = Linecook::Template

  attr_reader :test_dir

  def setup
    @test_dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry test_dir
  end

  #
  # erb
  #

  def test_erb_returns_template_for_filename
    filename = File.join(test_dir, "example.erb")
    File.open(filename, "w") {|io| io << "<%= 1 + 2 %>" }

    template = Template.new(filename)
    erb = template.erb
  
    assert_equal "3", erb.result
    assert_equal filename, erb.filename
  end
end