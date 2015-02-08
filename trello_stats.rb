class TrelloStats
  MINUTE = 60
  HOUR = 60 * MINUTE
  DAY = 24 * HOUR

  def initialize(board)
    @board = board
  end

  def show_se_ha_roto_completed_with_creation_time
    show_avg
    get_time_from_created_to_done[:info].sort_by { |card| card[:diff] }.reverse.each do |card|
      puts "  #{ card[:name] } -> #{ format_time(card[:diff]) }"
    end
    puts
  end

  def show_avg
    info = get_time_from_created_to_done
    puts "#{ @board.name } / #{ info[:list_name] } <-> AVG: #{ format_time(info[:avg_time]) }"
  end

  def get_time_from_created_to_done
    @time_from_created_to_done ||= calc_time_from_created_to_done
  end

  def show_completed_tasks_without_staging
    puts "%10s NO Staging =(" % @board.name.upcase
    tasks = get_completed_tasks_without_staging
    tasks.each do |task|
      puts task.name
    end
    puts
  end

  private

  def format_time(seconds)
    return '---' if seconds == 0
    seconds = seconds.to_i
    "#{ seconds / DAY }d #{ seconds % DAY / HOUR }:#{ seconds % HOUR / MINUTE }"
  end

  def calc_time_from_created_to_done
    total_time = 0
    action_info = get_se_ha_roto_cards.inject([]) do |a, card|
      actions = card.actions
      create_action = actions.detect { |action| action.type == 'createCard' || action.type == 'copyCard' }
      done_action = actions.detect do |action|
        action.type == 'updateCard' && action.data['listAfter'] && action.data['listAfter']['name'] =~ /Hecho/
      end
      card_time = (done_action.date - create_action.date).to_i
      total_time += card_time
      a << { name: card.name, created_at: create_action.date, done_at: done_action.date, diff: card_time }
      a
    end
    avg_time = action_info.size == 0 ? 0 : total_time / action_info.size
    { list_name: 'hecho', info: action_info, avg_time: avg_time }
  end

  def get_se_ha_roto_cards
    @board.lists[5].cards.select do |c|
      c.actions.detect do
        |a| a.data['list'] && a.data['list']['name'] == 'Se ha roto'
      end
    end
  end

  def get_completed_tasks_without_staging
    @board.lists[4].cards.select do |c|
      c.actions.none? do
        |a| a.data['list'] && a.data['list']['name'] == 'Edge (Validación)'
      end
    end
  end
end
