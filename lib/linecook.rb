require 'linecook/config'

module Linecook
  module_function

  def options(overrides = {})
    Config.options(overrides)
  end

  def setup(options = {})
    Config.setup(options)
  end
end
