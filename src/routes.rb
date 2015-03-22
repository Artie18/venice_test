require './graph'
require './floyd'

class Routes

  attr_reader :graph, :routes
  attr_reader :from, :to, :stops, :max_stops
  attr_reader :direct, :e_stops, :all_routes, :max_length

  def initialize(ribs)
    @direct = false

    @graph          = Graph.new(ribs)
    @direct_routes  = Floyd.new(@graph.to_a).to_h
    @routes         = Floyd.new(@graph.to_a).perform.to_h
  end

  # Set query
  #
  def from(from)
    @from = from
    self
  end

  def max_stops(m_stops)
    @max_stops = m_stops
    self
  end

  def max_length(m_length)
    @max_length = m_length
    self
  end

  def with_stops(e_stops)
    @exact_stops = e_stops
    self
  end

  def show_all_routes(a_routes = true)
    @all_routes = a_routes
    self
  end

  def to(to)
    @to = to
    self
  end

  def direct(direct = true)
    @direct = direct
    self
  end

  def through(th)
    @stops = []
    @stops << th
    self
  end

  def then_through(then_through)
    @stops << then_through
    self
  end
  #
  # Set query: END

  # Perform query universal method
  def perform
    options = { max_stops: @max_stops,
                exact_stops: @exact_stops,
                max_length: @max_length }
    return @graph.search_all_pathes(@from, @to, options) if @all_routes
    @stops.nil? ? no_stop_weight(@from, @to) : with_stops_weight
  end

  # Clear all attrs to reuse
  # Do not create new instances, so we don't perform new Floyd algrthm
  def clear
    @stops  = []
    @from   = nil
    @to     = nil
    @direct = false
    @max_stops = nil
    @exact_stops = nil
    @all_routes = false
    @max_length = nil
    self
  end

  # TODO: MOVE ALL PRIVATE SECTION TO GRAPH CLASS
  private

  def no_direct_route_for?(weight)
    weight == Float::INFINITY
  end

  def from?(from, route)
    from == route[:s_point]
  end

  def to?(to, route)
    to == route[:f_point]
  end

  # Finding root if no stop required
  def no_stop_weight(from, to)
    routes = @direct ? @direct_routes : @routes
    r = routes.find { |route|  from?(from, route) && to?(to, route) }[:weight]
    r.nil? ? Float::INFINITY : r
  end

  def all_the_stops
    ([] << @from << @stops << @to).flatten
  end

  def journeys
    all_the_stops.each_with_index.map do |st, i|
      [st, all_the_stops[i + 1]] unless all_the_stops[i + 1].nil?
    end.compact
  end

  # Finding routes throught some stations
  def with_stops_weight
    journeys.inject(0) do |weight, journey|
      weight += no_stop_weight(*journey)
    end
  end

  def first_part(stop)
    no_stop_weight(@from, stop)
  end

  def last_part(stop)
    no_stop_weight(stop, @to)
  end
end