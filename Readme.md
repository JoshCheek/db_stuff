# ===== Set stuff =====

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


# =====  Joins  =====

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

# =====  Lets see some of these in Sqlite  =====

Check out example.rb
