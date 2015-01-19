$:.unshift File.expand_path('../lib', __FILE__)
require 'linecook/version'

# Ronn is used to render roff from markdown
vendor_dir = 'vendor'
ronn_dir   = File.join(vendor_dir, 'ronn')
ronn_lib   = File.join(ronn_dir, 'lib')
ronn_exe   = File.join(ronn_dir, 'bin/ronn')
file ronn_exe do
  mkdir_p vendor_dir
  sh "git clone git://github.com/thinkerbot/ronn.git '#{vendor_dir}'"
end

# Manpages
readme = 'README.md'
linecook_1 = 'man/man1/linecook.1' 
file linecook_1 => [ronn_exe, readme] do
  mkdir_p File.dirname(linecook_1)
  sh "ruby -I#{ronn_lib} #{ronn_exe} -r --pipe --organization='#{Linecook::VERSION}' --date='#{Linecook::RELDATE}' < '#{readme}' > #{linecook_1}"
end

desc "make manpages"
task :manpages => linecook_1

desc "clean up manpages"
task :clean do
  rm linecook_1
end
