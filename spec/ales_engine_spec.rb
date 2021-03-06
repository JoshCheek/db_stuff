require 'ales_engine'
require 'sqlite3'

RSpec.describe AlesEngine do
  let :db do
    db = SQLite3::Database.new ':memory:'
    db.results_as_hash = true
    db
  end

  let :fruits do
    fruits = AlesEngine::Table.new(db, :fruits, id: :integer, name: :string)
    fruits.create_table
    fruits
  end

  it 'Big acceptance test', acceptance: true do
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
    expect(josh.id).to eq 3
    expect(josh.name).to eq 'Josh'

    nut_brown = ales.find_by(label: 'Nut Brown')
    expect(nut_brown.id).to eq    4
    expect(nut_brown.label).to eq 'Nut Brown'

    # going through associations
    # And now we need to figure out what we want the associations to be
    #
    # orders    = AlesEngine::Table.new(db, :orders, customer_id: :integer, ale_id: :integer)
    # customer_id | ale_id
    # ------------|-------
    #           3 |      4
    #           2 |      4
    #           2 |      1
    #           1 |      5
    # expect(nut_brown.customers.map(&:name)).to eq  ['Josh', 'Matt']
    # expect(nut_brown.customers.last.ales.map(&:label)).to eq ['Nut Brown', 'India Pale Ale']
  end

  describe AlesEngine::Table do
    describe 'create_table' do
      it 'creates the table if it dne' do
        bs = AlesEngine::Table.new(db, :bs, id: :integer)
        expect { db.execute 'select * from bs' }.to raise_error SQLite3::SQLException
        bs.create_table
        expect(db.execute 'select * from bs').to eq []
      end

      it 'leaves the table alone if it exists' do
        bs = AlesEngine::Table.new(db, :bs, id: :integer)
        db.execute('create table bs (id integer primary key autoincrement);')
        bs.create_table
        expect(db.execute 'select * from bs').to eq []
      end
    end


    describe 'add' do
      it 'adds the row to the table with the attributes in the appropriate columns' do
        expect(fruits.all).to be_empty
        fruits.add([{name: 'apple'}])
        expect(fruits.all.map &:name).to eq ['apple']
      end

      it 'accepts duplicate rows' do
        fruits.add([{name: 'apple'}])
        fruits.add([{name: 'apple'}])
        expect(fruits.all.map &:name).to eq ['apple', 'apple']
      end
    end


    describe 'find_by' do
      it 'returns the first record that matches the criteria' do
        fruits.add([{name: 'pear'}, {name: 'apple'}, {name: 'apple'}])
        expect(fruits.find_by(name: 'apple').id).to eq 2
        expect(fruits.find_by(id: 3, name: 'apple').id).to eq 3
        expect(fruits.find_by(id: 3, name: 'pear')).to eq nil
      end
    end
  end
end
