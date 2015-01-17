#!/usr/bin/env ruby
require File.expand_path('../../helper', __FILE__)
require 'linecook/config'
require 'tmpdir'
require 'fileutils'

class Linecook::ConfigTest < Test::Unit::TestCase
  Config = Linecook::Config

  attr_reader :test_dir

  def setup
    @test_dir = Dir.mktmpdir
  end

  def teardown
    FileUtils.remove_entry test_dir
  end

  #
  # self.setup
  #

  def test_Config_setup_returns_config_instance_with_defaults
    config = Config.setup
    assert_equal Config.default_template_dirs, config.template_dirs
  end

  def test_Config_setup_sets_template_dirs_from_path
    config = Config.setup(:path => "a:b:c")
    assert_equal ["a", "b", "c"], config.template_dirs
  end

  #
  # template_files
  #

  def test_template_files_returns_all_template_files_found_on_path
    test_dir_a = Dir.mktmpdir
    test_dir_b = Dir.mktmpdir

    begin
      FileUtils.touch "#{test_dir_a}/x.erb"
      FileUtils.touch "#{test_dir_a}/y.erb"
      FileUtils.touch "#{test_dir_b}/y.erb"
      FileUtils.touch "#{test_dir_b}/z.erb"

      config = Config.new(:template_dirs => [test_dir_a, test_dir_b])
      assert_equal({
        "x" => "#{test_dir_a}/x.erb",
        "y" => "#{test_dir_a}/y.erb",
        "z" => "#{test_dir_b}/z.erb",
      }, config.template_files)
    ensure
      FileUtils.remove_entry test_dir_a
      FileUtils.remove_entry test_dir_b
    end
  end

  #
  # templates
  #

  def test_templates_returns_all_templates_found_on_path
    test_dir_a = Dir.mktmpdir
    test_dir_b = Dir.mktmpdir

    begin
      FileUtils.touch "#{test_dir_a}/x.erb"
      FileUtils.touch "#{test_dir_a}/y.erb"
      FileUtils.touch "#{test_dir_b}/y.erb"
      FileUtils.touch "#{test_dir_b}/z.erb"

      config = Config.new(:template_dirs => [test_dir_a, test_dir_b])
      assert_equal ["x", "y", "z"], config.templates.keys.sort
      assert_equal "#{test_dir_a}/x.erb", config.templates["x"].filename
      assert_equal "#{test_dir_a}/y.erb", config.templates["y"].filename
      assert_equal "#{test_dir_b}/z.erb", config.templates["z"].filename
    ensure
      FileUtils.remove_entry test_dir_a
      FileUtils.remove_entry test_dir_b
    end
  end
end
