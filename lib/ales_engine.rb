module AlesEngine
  class Table
    attr_accessor :db, :table_name, :attributes
    def initialize(db, table_name, attributes)
      self.db         = db
      self.table_name = table_name
      self.attributes = attributes
    end

    def create_table
      db.execute("create table if not exists #{table_name} (#{column_definitions.join(', ')});")
    end

    private

    def column_definitions
      attributes.map do |name, type|
        if name == :id
          "#{name} integer primary key autoincrement"
        elsif type == :string
          "#{name} text"
        elsif type == :integer
          "#{name} integer"
        end
      end
    end
  end
end
