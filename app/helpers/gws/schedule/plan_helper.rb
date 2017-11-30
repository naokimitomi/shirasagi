module Gws::Schedule::PlanHelper
  def search_query
    params.select { |k, v| k == 's' }.to_query
  end

  def term(item)
    if item.allday?
      dates = [item.start_at.to_date, item.end_at.to_date].uniq
    else
      dates = [item.start_at, item.end_at].uniq
    end
    dates.map! { |m| I18n.l(m, format: :gws_long) }
    return dates[0] if dates.size == 1

    dates[1].split(/ /).each_with_index do |s, i|
      next if s == dates[0].split(/ /)[i]
      return [dates[0], dates[1].split(/ /)[i..-1].join(' ')].join(' - ')
    end
  end

  def calendar_format(plans, opts = {})
    events = plans.map { |m| m.calendar_format(@cur_user, @cur_site) }
    return events unless opts[:holiday]

    events += calendar_holidays opts[:holiday][0], opts[:holiday][1]
    events += group_holidays opts[:holiday][0], opts[:holiday][1]
    events += calender_todos(opts[:holiday][0], opts[:holiday][1])
    events
  end

  def group_holidays(start_at, end_at)
    Gws::Schedule::Holiday.site(@cur_site).and_public.
      search(start: start_at, end: end_at).
      map(&:calendar_format)
  end

  def calendar_holidays(start_at, end_at)
    HolidayJapan.between(start_at, end_at).map do |date, name|
      { className: 'fc-holiday', title: "  #{name}", start: date, allDay: true, editable: false, noPopup: true }
    end
  end

  def calender_todos(start_at, end_at)
    result = Gws::Schedule::Todo.site(@cur_site).
      allow(:read, @cur_user, site: @cur_site).active.
      search(start: start_at, end: end_at).
      map do |todo|
        result = todo.calendar_format(@cur_user, @cur_site)
        result[:restUrl] = gws_schedule_todos_path
        result
      end
    result
  end
end
