require 'date'
require './todoist.rb'

todoist = Todoist.new

date = Date.today - 7
p todoist.get_completed_items(since: date)