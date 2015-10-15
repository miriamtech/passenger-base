#!/usr/bin/env ruby

ALLOWED = 0
PROHIBITED = 101
FALLBACK = 106

package = ARGV[0]
actions = ARGV[1]
action = ARGV[1].split(" ").first

# Handle nginx updates that may come in via unattended-upgrades
exit PROHIBITED unless package == 'nginx'
if %w(reload force-reload).include?(action)
  exit ALLOWED
elsif %w(start restart).include?(action)
  # runit restarts after stop
  puts "stop"
  exit FALLBACK
else
  exit PROHIBITED
end
