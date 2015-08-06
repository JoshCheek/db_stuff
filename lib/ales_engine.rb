module AlesEngine
  class Table
    def self.record_class_for(attributes)
      attribute_names = attributes.keys.map(&:to_s).map(&:freeze)

      Class.new do
        define_singleton_method(:attribute_names) { attribute_names }
        attr_accessor *attributes.keys

        def initialize(attributes)
          self.class.attribute_names.each do |name|
            __send__ "#{name}=", attributes[name] if attributes.key? name
          end
        end
      end
    end

    attr_accessor :db, :table_name, :attributes, :record_class

    def initialize(db, table_name, attributes)
      self.db           = db
      self.table_name   = table_name
      self.attributes   = attributes
      self.record_class = self.class.record_class_for(attributes)
    end

    def create_table
      db.execute("create table if not exists #{table_name} (#{column_definitions.join(', ')});")
    end

    def all
      db.execute("select * from #{table_name};")
        .map { |attrs| record_class.new attrs }
    end

    def add(record_attributes)
      keys = (record_attributes[0] || {}).keys
      name_sql = keys.join(', ')

      values_sql = record_attributes.map { |attrs|
        sql = keys.map { |key| attrs[key].inspect }.join(", ")
        "(#{sql})"
      }.join(", ")

      insert_sql = "insert into #{table_name} (#{name_sql}) values #{values_sql};"
      db.execute(insert_sql)
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
