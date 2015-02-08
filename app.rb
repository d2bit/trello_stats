require 'trello'
require_relative 'trello_config'
require_relative 'trello_stats'

BOARDS = { mantenimiento: 'Web Mantenimiento', desarrollo: 'Web Desarrollo' }

boards = Trello::Board.all
desarrollo = boards.detect { |board| BOARDS[:desarrollo] == board.name }
mantenimiento = boards.detect { |board| BOARDS[:mantenimiento] == board.name }

mantenimiento_stats = TrelloStats.new mantenimiento
mantenimiento_stats.show_se_ha_roto_completed_with_creation_time

desarrollo_stats = TrelloStats.new desarrollo
desarrollo_stats.show_completed_tasks_without_staging
mantenimiento_stats.show_completed_tasks_without_staging
