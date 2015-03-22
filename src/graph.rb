class Graph

  # A - 1
  # B - 2
  # C - 3
  # D - 4
  # E - 5

  INPUT_LETTERS = ('A'..'E').to_a

  attr_reader :nodes, :ribs, :array

  attr_reader :max_stops, :exact_stops, :max_length, :floyd

  def initialize(ribs_as_h)
    hash_with_arr_val = Hash.new { |hash, key| hash[key] = [] }
    @ribs  = ribs_as_h
    @pathes = ribs_as_h.inject(hash_with_arr_val) do |hash, r|
      hash[r[:s_point]] << r[:f_point]
      hash
    end
    @nodes = sorted_nodes(ribs_as_h)
  end

  def search_all_pathes(from, to, o = {})
    @max_stops    = o[:max_stops]
    return all_pathes_with_max_stops(from, to, [], a=[]) if @max_stops
    @exact_stops  = o[:exact_stops]
    return all_pathes_with_exact_stops(from, to, [], a=[]) if @exact_stops
    @max_length   = o[:max_length]
    return all_pathes_with_max_length(from, to, [], a=[]) if @max_length
    'NO SUCH ROUTE'
  end

  def to_a
    input_array = INPUT_LETTERS.inject({}) do |hash, letter|
      hash.merge({letter => []})
    end
    @nodes.map { |letter| row(input_array[letter], letter) }
  end

  def to_h
    @nodes
  end

  private

  def current_route_length(c_res)
    return 0 if c_res.length < 2
    c_res.each_with_index.inject(0) do |count, (letter, i)|
      path = @ribs.find do |r|
        r[:s_point] == letter && r[:f_point] == c_res[i + 1] && !r[:weight].nil?
      end unless c_res[i + 1].nil?
      count += path[:weight].to_i unless path.nil?
      count
    end
  end

  def condition_for_all_pathes(current_res)
    return -> { current_res.length < @max_stops + 1 } unless @max_stops.nil?
    return -> { current_res.length == @exact_stops + 1} unless @exact_stops.nil?
    return -> do
      ln = current_route_length(current_res)
      ln < @max_length && ln > 0
    end unless @max_length.nil?
    -> { true }
  end

  ## TODO: Make next 3 functions reusable
  def all_pathes_with_max_length(from, to, c_res, result)
    c_res = c_res + [from]
    if from == to && condition_for_all_pathes(c_res).call
      result << c_res
    end
    @pathes[from].each do |v|
      if current_route_length(c_res) < @max_length
        all_pathes_with_max_length(v, to, c_res, result)
      end
    end
    result
  end

  def all_pathes_with_exact_stops(from, to, c_res, result)
    c_res = c_res + [from]
    if from == to && condition_for_all_pathes(c_res).call
      result << c_res
    end
    @pathes[from].each do |v|
      if c_res.length < @exact_stops + 1
        all_pathes_with_exact_stops(v, to, c_res, result)
      end
    end
    result
  end

  def all_pathes_with_max_stops(from, to, c_res, result)
    c_res = c_res + [from]
    if from == to && condition_for_all_pathes(c_res).call
      result << c_res
    end
    @pathes[from].each do |v|
      if c_res.length < @max_stops
        all_pathes_with_max_stops(v, to, c_res, result)
      end
    end
    result
  end

  def row(array, letter)
    INPUT_LETTERS.each { |l| array << nil }
    @ribs.inject(array) do |arr, rib|
      if rib[:s_point] == letter
        arr[INPUT_LETTERS.index(rib[:f_point])] = rib[:weight].to_i
      end
      arr
    end
  end

  def sorted_nodes(ribs_as_h)
    @nodes ||= ribs.inject([]) do |array, rib|
      array << rib[:s_point] << rib[:f_point]
    end.uniq.sort_by(&:downcase)
  end


end