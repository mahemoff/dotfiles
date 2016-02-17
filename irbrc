require 'irb/ext/save-history'
IRB.conf[:SAVE_HISTORY] = 1000
IRB.conf[:HISTORY_FILE] = "#{ENV['HOME']}/.irb-history"
require "awesome_print"
AwesomePrint.irb!
Signal.trap('SIGWINCH', proc { y, x = `stty size`.split.map(&:to_i); Hirb::View.resize(x, y) if defined? Hirb } ) # http://stackoverflow.com/a/12108289/18706
