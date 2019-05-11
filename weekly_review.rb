require 'date'
require './todoist.rb'

todoist = Todoist.new

date = Date.today - 7
todoist.get_completed_items(since: date).each {|item| puts item["content"]}