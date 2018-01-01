# yadm

Yet Another Dependencies Manager

## What is it for?
Simple implementation of dependency container.

Imagine, you have two coupled classes. For example `BillingManager` and `EmailNotifier`.
`BillingManager` uses notifier to notify user about each money transaction.
Typically in Ruby you'll define methods anywhere (e. g. in controllers) you'll need `BillingManager` like that:

```ruby
def billing_manager
  BillingManager.new(EmailNotifier.new)
end
```

But hey! What shall happens if you'll need to use another notifier, for example SmsNotifier?
Or add extra parameters to `BillingManager`'s constructor? Or completely change notifiers' constructor? 
That's it! You'll have to fix all `BillingManager.new` calls.

And that how it could be solved with `Yadm`:

```ruby
# on application initialize
manager = Yadm::Manager.new
manager.register(:notifier){ EmailNotifier.new }
manager.register(:billing_manager){ |m| BillingManager.new(m.resolve(:notifier)) } 
```

Now your controllers should not know about billing manager concrete class or it's dependencies.

```ruby
def billing_manager
  manager.resolve(:billing_manager)
end
```

And all you have to do if you need change something is to fix initialization:

```ruby
# on application initialize
manager = Yadm::Manager.new

manager.register(:notifier) do |m|
  SmsNotifier.new(m.resolve(:sms_notifier_dependency))
end

manager.register(:billing_manager) do |m|
  BillingManager.new(m.resolve(:notifier), m.resolve(:other_billing_dependency)) 
end
```

# Disclaimer

This is just my experiment, a part of my hobby.
It wasn't ever tested in real projects and possibly contains tons of bugs.


# Usage

First of all you need to initialize object.

```ruby
manager = Yadm::Manager.new
```

Now `manager` is ready for your dependencies.

## Object registration

You can use manager to store object. It possible to store whatever: String, Lambda, Integer, Class or any other kind of object.

```ruby
manager.register_object(:str, "my string")
manager.register_object(:lambda, ->{ "something" })
manager.register_object(:int, 42)
manager.register_object(:class, Float)
manager.register_object(:arr, [])
``` 

## Resolving.

Now you can resolve any previously stored object.

```ruby
manager.resolve(:str) #=> "my string"
manager.resolve(:lambda).call #=> "something"
manager.resolve(:int) #=> 42
manager.resolve(:class) #=> Float
manager.resolve(:arr) #=> []
```

**Warning**
    Actually, objects could be mutable.

```ruby
manager.resolve(:arr).push(100500)
manager.resolve(:arr) #=> [100500]
```

But please, make sure, that you really need this kind of global objects. It could thread unsafe.

## Advanced registration

Method `#register` provides more powerful and flexible way to register objects.
Unlike `#register_object` it don't takes initialized object, but block, which initialize it.

In block you can use previously registered objects as dependencies. And it is no matter if dependency is already registered or not.
Block will be used only when you'll need object.

```ruby
manager.register(:foo) { Foo.new }

manager.register(:bar) do |m|
  foo = m.resolve(:foo) # already registered
  baz = m.resolve(:baz) # will be registered later
  Bar.new(foo, baz)
end

manager.register_object(:baz, "Baz")

manager.resolve(:bar) #=> #<Bar @foo=#<Foo> @baz="Baz">
``` 

Blocks could be useful for dynamic code reload. E.g. Rails development mode.

## Preparing

Objects, registered with `#register` normally will be initialized every time `#resolve` is called.
If you need to reduce count of memory allocations and you don't need to deal with code hot reload (e.g. at production) `#prepare!` could be useful for you.
It initializes and saves all registered objects to cache. So `#resolve` will return same object for same key every time.

```ruby
manager.register(:c_time) { Time.now }
manager.resolve(:c_time) #=> 2018-01-01 20:11:47 +0300
manager.resolve(:c_time) #=> 2018-01-01 20:11:48 +0300
manager.resolve(:c_time) #=> 2018-01-01 20:11:49 +0300

# etc
manager.prepare!
manager.resolve(:c_time) #=> 2018-01-01 20:12:27 +0300 
manager.resolve(:c_time) #=> 2018-01-01 20:12:27 +0300 
manager.resolve(:c_time) #=> 2018-01-01 20:12:27 +0300 
```

**Warning 1**
Like object, registered with `#register_object`, prepare object could be mutable.

```ruby
manager.register(:prepared_array) { [] }
manager.prepare!
manager.resolve(:prepared_array).push(42)
manager.resolve(:prepared_array) #=> [42]
```

So this is still unsafe to use it this way.

**Warning 2**

`#prepare` will cache only already registered objects.
If you have registered object after manager was prepared - that object will be initialized every time `#resolve` is called.

```ruby
manager.register(:foo) { Foo.new }
manager.prepare!
manager.register(:bar) { Bar.new }

manager.resolve(:foo) # same instance every time
manager.resolve(:bar) # new instance every time

manager.prepare! #recache all object

manager.resolve(:foo) # same instance every time, but not the same as before
manager.resolve(:bar) # same instance every time
```

## YAML config

For people who like programming configs. Simply call `Yadm.load_yaml` and specify `.yml` file as parameter.
At root it should have array. Each element is object to register. Order of objects isn't important. 
Each one should have `name` and `class`.
`name` - identifier (key) to register object
`class` - string representation of constant to use (e.g. `"Array"` or `"Foo"` or `"::Bar::Baz"`)
`dependencies` array should include identifiers for objects that will be used as dependencies. Order is important.

Imagine that `conf.yml` contains:

```yaml
- name: "foo"
  class: "Foo"
- name: "bar"
  class: "Bar"
  dependencies:
    - "foo"
    - "baz" 
- name: "baz"
  class: "Baz"
```

```ruby
manager = Yadm.load_yaml("conf.yml")
manager.resolve(:bar) #=> #<Bar @foo=#<Foo> @baz=#<Baz>>
```
