#!/usr/bin/env ruby
require File.expand_path('../../helper', __FILE__)
require 'linecook/template'

class Linecook::TemplateTest < Test::Unit::TestCase
  Template = Linecook::Template

  attr_reader :test_dir

  def setup
    @test_dir = Dir.mktmpdir
  end

  def create_template(properties = {}, template_str = "<%= 1 + 2 %>")
    template_file = File.join(test_dir, "example.lc")
    File.open(template_file, "w") do |io|
      io.puts YAML.dump(properties)[4..-1]
      io.puts "---"
      io << template_str
    end
    Template.new(template_file)
  end

  def teardown
    FileUtils.remove_entry test_dir
  end

  #
  # properties
  #

  def test_properties_returns_properties_from_template_file
    properties = {"key" => "value"}
    template = create_template(properties)
    assert_equal properties, template.properties
  end

  #
  # context
  #

  def test_context_returns_context_wrapping_fields
    template = create_template
    context  = template.context([1, 2, 3])
    assert_equal [1,2,3], context.fields
  end

  def test_context_assigns_fields_as_per_properties
    template = create_template("fields" => {"a" => nil, "b" => nil})
    context = template.context([1, 2, 3, 4, 5])
    assert_equal [1, 2, 3, 4, 5], context.fields
    assert_equal 1, context.a
    assert_equal 2, context.b
  end

  #
  # erb
  #

  def test_erb_returns_template_for_template_file
    template = create_template
    erb = template.erb
    assert_equal "3", erb.result
    assert_equal template.template_file, erb.filename
  end
end