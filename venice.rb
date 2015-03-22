require './routes'

ribs   = []

ARGV.each do |arg|
  ribs << {
    s_point: arg[0],
    f_point: arg[1],
    weight:  arg[2]
  }
end

routes = Routes.new(ribs)
res = []

# Make one big rescue to give normal response for BETA Product
begin
  # A - B - C
  # 1
  res << routes.from('A').to('C').through('B').direct.perform
  # A - D
  # 2
  res << routes.clear.from('A').to('D').direct.perform
  # A - D - C
  # 3
  res << routes.clear.from('A').to('C').through('D').direct.perform
  # A - E - B - C - D
  # 4
  res << routes.clear.from('A').to('D').through('E').then_through('B').then_through('C').direct.perform
  # A - E - D
  # 5
  res << routes.clear.from('A').to('D').through('E').direct.perform
  # C - C (max 3 stops)
  # 6
  res << routes.clear.from('C').to('C').show_all_routes.max_stops(3).perform.length
  # A - C (4 stops)
  # 7
  res << routes.clear.from('A').to('C').show_all_routes.with_stops(4).perform.length
  # A - C
  # 8
  res << routes.clear.from('A').to('C').perform
  # B - B
  # 9
  res << routes.clear.from('B').to('B').perform
  # C - C (max weight 30)
  # 10
  res << routes.clear.from('C').to('C').show_all_routes.max_length(30).perform.length
rescue
  res = ['Something went wrong! Product is in BETA']
end


res.each_with_index do |r, i|
  r = 'NO SUCH ROUTE' if r == Float::INFINITY
  p "\##{i + 1}: #{r}"
end





