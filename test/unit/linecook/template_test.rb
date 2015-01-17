#!/usr/bin/env ruby
require File.expand_path('../../helper', __FILE__)
require 'linecook/template'

class Linecook::TemplateTest < Test::Unit::TestCase
  Template = Linecook::Template

  attr_reader :test_dir, :template_file, :attributes_file, :template

  def setup
    @test_dir = Dir.mktmpdir
    @template_file = File.join(test_dir, "example.erb")
    @attributes_file = File.join(test_dir, "example.yml")

    File.open(@template_file, "w") {|io| io << "<%= 1 + 2 %>" }
    @template = Template.new(template_file)
  end

  def teardown
    FileUtils.remove_entry test_dir
  end

  #
  # attrs
  #

  def test_attrs_returns_attrs_from_attributes_file
    attrs = {"key" => "value"}
    File.open(attributes_file, "w") {|io| io << YAML.dump(attrs) }

    assert_equal attrs, template.attrs
  end

  #
  # context
  #

  def test_context_returns_context_wrapping_args
    context = template.context([1, 2, 3])
    assert_equal [1,2,3], context.args
  end

  def test_context_assigns_argument_names_as_per_attributes_file
    attrs = {"args" => ["a", "b"]}
    File.open(attributes_file, "w") {|io| io << YAML.dump(attrs) }

    context = template.context([1, 2, 3, 4, 5])
    assert_equal [1, 2, 3, 4, 5], context.args
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