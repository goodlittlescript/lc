$:.unshift File.expand_path('../../../lib', __FILE__)

require 'rubygems'
require 'bundler'
Bundler.setup

require 'test/unit'
require 'tmpdir'
require 'fileutils'
