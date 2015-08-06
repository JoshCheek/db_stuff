require 'ales_engine'
require 'sqlite3'

RSpec.describe AlesEngine do
  it 'Big acceptance test', acceptance: true do
    db = SQLite3::Database.new ':memory:'

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

    nut_brown = ales.find_by(name: 'Nut Brown')
    expect(nut_brown.id).to eq    4
    expect(nut_brown.label).to eq 'Nut Brown'

    # going through associations
    # orders    = AlesEngine::Table.new(db, :orders, customer_id: :integer, ale_id: :integer)
    # customer_id | ale_id
    # ------------|-------
    #           3 |      4
    #           2 |      4
    #           2 |      1
    #           1 |      5
    expect(nut_brown.customers.map(&:name)).to eq  ['Josh', 'Matt']
    expect(nut_brown.customers.last.ales.map(&:label)).to eq ['Nut Brown', 'India Pale Ale']
  end

  describe AlesEngine::Table do
    let(:db) { SQLite3::Database.new ':memory:' }

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
  end
end
