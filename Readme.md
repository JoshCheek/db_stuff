Set stuff
=========

```ruby
# Sets: hashes where the values are "true".

# here are some examples
require 'set'                # => true
Set[1,2,3,4,5] ^ Set[2,5,8]  # => #<Set: {8, 1, 3, 4}>

# Intersection - elements in both
Set[1,2,3,4,5] & Set[2,5,8]  # => #<Set: {2, 5}>

# Union - elements in either
Set[1,2,3,4,5] | Set[2,5,8]  # => #<Set: {1, 2, 3, 4, 5, 8}>

# Difference - elements in one, but not the other
Set[*1..5] - Set[2,5,8]  # => #<Set: {1, 3, 4}>
Set[2,5,8] - Set[*1..5]  # => #<Set: {8}>

# fun :)
[ Set[2,5,8],                                        # => #<Set: {2, 5, 8}>
  Set[5,6]                                           # => #<Set: {5, 6}>
].reduce(Set[*1..5]) { |left, right| left & right }  # => #<Set: {5}>
```


Joins
=====

Set operations on rows of tables
You can also think about these visually: http://blog.codinghorror.com/a-visual-explanation-of-sql-joins/

Docs for constructing sql:

* create table: [https://www.sqlite.org/lang_createtable.html](https://www.sqlite.org/lang_createtable.html)
* select:       [https://www.sqlite.org/lang_select.html](https://www.sqlite.org/lang_select.html)
* insert:       [https://www.sqlite.org/lang_insert.html](https://www.sqlite.org/lang_insert.html)
* update:       [https://www.sqlite.org/lang_update.html](https://www.sqlite.org/lang_update.html)
* delete:       [https://www.sqlite.org/lang_delete.html](https://www.sqlite.org/lang_delete.html)


```sql
SELECT customers.name, fruits.name, sales.created_at
FROM fruits
INNER JOIN sales     ON fruits.id         = sales.fruit_id
INNER JOIN customers ON sales.customer_id = customers.id;
```

Lets see some of these in Sqlite
================================

Check out example.rb


Lets build an ORM!
==================

We start by deciding how we should be able to use it,
that way we know what we're making.

After some discussion, we decide we should be able to do this:

```ruby
# orm
customers = AlesEngine::Table.new(db, :customers, id: :integer, name:  :string)
ales      = AlesEngine::Table.new(db, :ales,      id: :integer, label: :string)

customers.create_table
ales.create_table

# inserting data
customers.add([{name: "Russell"}, {name: "Matt"}])
customers.add([{name: "Josh"}])
ales.add([
  {label: 'India Pale Ale'},
  {label: 'Denver Pale Ale'},
  {label: 'English Brown'},
  {label: 'Nut Brown'},
  {label: 'Ginger Ale'},
])

# querying data
josh = customers.find_by(name: 'Josh')
josh.id    # =>  3
josh.name  # => 'Josh'

nut_brown = ales.find_by(label: 'Nut Brown')
nut_brown.id     # => 4
nut_brown.label  # => 'Nut Brown'
```

We decide to put off figuring out what the associations should probably look like.
Mostly because no one offered any ideas, but also because everything we ever make is wrong,
so we'll wait until we get close to it,
so that when we make the decision, we'll have a better feel for what it looks like,
and reduce the probability of our wrongness.

We turn our example into an acceptance test: "If this example works, then our code is acceptable".

Then we run the tests until they get to the `create_table` statement,
which requires some code to actually do something. Our select is a questionable verification,
but given that we only had a little over an hour, we rolled with it.

We then proceeded to add unit tests as necessary, to progress our code towards the goal.
And in the end, we did successfully get it to work.

Note that our tests are still very high-level.
This is because we're so early on in this code (first hour)
that we don't know how the design will pan out.
The less confidence we have in a piece of code, the higher up we want to test.
Once it becomes cumbersome to test at this level, we can use that as a heuristic
to go to a lower level.
Or if we begin to see some behaviour congealing,
then we gain confidence in that piece of code, and can test much closer to it.

In the end, our high level test was permissive enough to allow us to get it working,
though there were a few occasions where the feedback of the failures was poor.
This is the downside of high-level tests, poorer feedback, because you're further away
from the code you're trying to implement. It's part of the heuristic,
if you can't get good enough feedback about failures, you probably want to test at a lower level.
And if you can't make reasonable changes without breaking tests,
you probably want to test at a higher level.

Where would we go from here? Probably to associations.
In general, you want as little code and tests as possible until
you begin to gain confidence in the design. So, do very little,
keep the inertia of the code as light as possible, and then
add the features that are most likely to throw a wrench in what you've done so far,
as early as possible, while the inertia is still light, and it is still
easy to change the direction of the codebase (you want to fix one or two
query methods, not one hundred or two hundred).
