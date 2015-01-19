#!/usr/bin/env ruby
require File.expand_path('../../helper', __FILE__)
require 'linecook/template'

class Linecook::TemplateTest < Test::Unit::TestCase
  Template = Linecook::Template

  attr_reader :test_dir, :template_file, :properties_file, :template

  def setup
    @test_dir = Dir.mktmpdir
    @template_file = File.join(test_dir, "example.erb")
    @properties_file = File.join(test_dir, "example.yml")

    File.open(@template_file, "w") {|io| io << "<%= 1 + 2 %>" }
    @template = Template.new(template_file)
  end

  def teardown
    FileUtils.remove_entry test_dir
  end

  #
  # properties
  #

  def test_properties_returns_properties_from_properties_file
    properties = {"key" => "value"}
    File.open(properties_file, "w") {|io| io << YAML.dump(properties) }

    assert_equal properties, template.properties
  end

  #
  # context
  #

  def test_context_returns_context_wrapping_fields
    context = template.context([1, 2, 3])
    assert_equal [1,2,3], context.fields
  end

  def test_context_assigns_fieldument_names_as_per_properties_file
    attrs = {"fields" => ["a", "b"]}
    File.open(properties_file, "w") {|io| io << YAML.dump(attrs) }

    context = template.context([1, 2, 3, 4, 5])
    assert_equal [1, 2, 3, 4, 5], context.fields
    assert_equal 1, context.a
    assert_equal 2, context.b
  end

  #
  # erb
  #

  def test_erb_returns_template_for_template_file
    erb = template.erb
    assert_equal "3", erb.result
    assert_equal template_file, erb.filename
  end
end