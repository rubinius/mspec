class Spy
  attr_accessor :object, :block, :record, :yields

  def initialize(object)
    @object = object
    @record = []
    @yields = []
    @block = lambda { |*args| @yields << args; @b.call(*args) } # yield(*args) }
  end

  def method_missing(m, *args, &b)
    @record << m << args
    @b = b
    @object.send(m, *args, &@block)
  end
end

def spy(a)
  x = Spy.new a
  yield(x)
  p x.record, x.yields
end

spy("abc") { |a| p a.scan(/b/) { |x| "d" } }
