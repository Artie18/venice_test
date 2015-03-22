class Floyd

  INPUT_LETTERS = ('A'..'E').to_a

  attr_reader :number

  def initialize(graph = [], pre = [])
    @graph = graph.to_a
    @pre = pre
    graph.each_index do |i|
      pre[i] = []
      graph.each_index do |j|
        pre[i][j] = i + 1
      end
    end
  end

  # Perform floyd's algrthm
  # TODO: try to make it smaller
  def perform
    @graph.each_index do |k|
      @graph.each_index do |i|
        @graph.each_index do |j|
          if @graph[i][j].nil? && !@graph[i][k].nil? && !@graph[k][j].nil?
            @graph[i][j] = @graph[i][k] + @graph[k][j]
            @pre[i][j] = @pre[k][j]
          elsif !@graph[i][k].nil? && !@graph[k][j].nil? && (@graph[i][j] > @graph[i][k] + @graph[k][j])
            @graph[i][j] = @graph[i][k] + @graph[k][j]
            @pre[i][j] = @pre[k][j]
          end
        end
      end
    end
    self
  end

  def to_h
    res = []
    @graph.each_index do |i|
      @graph[i].each_index do |j|
        res << {
          s_point: INPUT_LETTERS[i],
          f_point: INPUT_LETTERS[j],
          weight: @graph[i][j]
        }
      end
    end
    res
  end

end
