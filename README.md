# MSpec

MSpec is a framework for writing executable specifications. Its primary
purpose is to provide a framework for RubySpec, but it is suitable for general
usage. It uses the fewest Ruby features possible to be suitable for beginning
Ruby implementations. All Ruby features that MSpec uses are detailed in a
separate test suite, called [laces] [1], included with MSpec.


## Table of Contents

1. [Syntax Introduction]()
1. [Glossary]()

## Syntax Introduction

MSpec does not define any methods on any Ruby objects other than its own
objects created to execute specifications, or for mocking as requested
explicitly by the specification. In no case does MSpec define methods
globally. MSpec takes inspiration from other testing frameworks, especially
[RSpec](http://rspec.info) and [Bacon](https://github.com/chneukirchen/bacon).

The following is a brief introduction to MSpec syntax. For complete
documentation for each feature, see the appropriate section below.

MSpec adopts the basic structure of RSpec for grouping specifications:

```ruby
describe "Cat#meow" do
  context "when hungry" do
    it "sounds strident" do
    end
  end
end
```

MSpec also provides for shared groups of specs:

```ruby
shared :animal_speak do
  it "makes a sound" do
  end
end
```

In all other aspects, MSpec differs fairly significantly from RSpec.

The primary concept in MSpec is a _verification_ (as opposed to an
_expectation_ in RSpec). A _verification expression_ is introduced by the
`verify` method, which is only defined on the `MSpec::Example` class.

The simplest verification asserts an identity between the subject and another
object:

```ruby
verify(a).is nil
```

In this example, the `is` method essentially verifies that `a.equal? nil` is
true. Note that we are not using the _matcher_ terminology of RSpec here. The
reason for this will be clear as we examine other forms of verification
expressions.

The inverse of this simple form is also possible:

```ruby
verify(a).is.not nil
```

The next form of `verify` takes a block:

```ruby
verify { Cat.new }.raises(InvalidPrideError)
```

The final form of `verify` takes neither argument nor block. This example
shows how shared specifications are verified:

```ruby
verify.behavior(:animal_speak)
```

The `verify` syntax includes some sugar. The following are equivalent:

```ruby
verify(a).eq 1
verify(a).is.eq.to 1
```

These forms again permit an inverse expression:

```ruby
verify(a).does.not.eq 1
verify(a).is.not.eq.to 1
```

There are also contractions:

```ruby
verify(a).doesnt.eq 1
verify(a).isnt.eq.to 1
```

Both disjunction and conjunctions are valid verification expressions:

```ruby
verify(a).gt.or.eq 10
verify(a).lt(2).or.gt(5)
verify(a).eq(2).or.eq(5).or.eq(8)
```

The verification expressions are consistent for test spies and mocks. In the
following verification, the value `a` may be a normal object or a mock:

```ruby
verify(a).receives(:meow).and.yields(1, 2, 3).and.returns(9)
a.meow { |a, b, c| ... }
```

The more terse syntax is also valid:

```ruby
verify(a).receives(:meow).yields(1, 2, 3).returns(9)
```

The negative syntax is not unexpected:

```ruby
verify(a).doesnt.receive(:meow)
```

For test spies, the verification expression follows the action:

```ruby
spy(a) { |a| a.meow }
verify(a).received(:meow).yielded(1, 2, 3).and.returned(9)
```

Again, the negative follows:

```ruby
spy(a) { |a| a.meow }
verify(a).didnt.receive(:woof)
```

The syntax for stubs is similar:

```ruby
stub(a).to.receive(:meow).yield(1, 2, 3).and.return(9)
a.meow
```


## Glossary

verification:

verification expression:

[1]: http://rubini.us "Evan Phoenix introduced the idea of laces in Rubinius"

