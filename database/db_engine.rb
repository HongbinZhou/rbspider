require "active_record"
require "date"

module DatabaseEngine
  def self.save(object)
    if object.respond_to?("database_to_save") && object.respond_to?("table_to_save")
      if !table_exists?(object.database_to_save, object.table_to_save + 's')
        setup_table(object.database_to_save, object.table_to_save + 's', object)
      end
      begin
        Kernel.const_get(object.table_to_save.capitalize + 's').new(object).save!
      rescue
        if Kernel.const_set(object.table_to_save.capitalize + "s", Class.new(ActiveRecord::Base)).new(object).save!
          puts "Info: object saved"
        else
          puts "Error: object saved failed"
        end
      end
    else
      raise "Exception: Cannot save your object, make sure your object is inherited from ParserResult"
    end
  end

  private
  def self.table_exists?(db_name, table_name)
    if connect_db(db_name)
      ActiveRecord::Base.connection.table_exists? "#{table_name}"
    end
  end

  def self.setup_table(db_name, table_name, object)
    if db_name && table_name && object.keys.length > 0
      if connect_db(db_name)
        ActiveRecord::Schema.define do
          create_table :"#{table_name}" do |table|
            object.keys.each do |column_name|
              if object[column_name].is_a?(DateTime)
                table.column "#{column_name}", "datetime"
              elsif object[column_name].is_a?(Integer)
                table.column "#{column_name}", "integer"
              elsif object[column_name].is_a?(Float)
                table.column "#{column_name}", "float"
              else
                table.column "#{column_name}", "text"
              end
            end
          end
        end
      else
        raise "Exception: cannot connect to database #{db_name}"
      end
    else
      raise "Exception: database name and table_name not given yet in setup_table"
    end
  end

  def self.connect_db(db_name)
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
                                            :database => "#{db_name}")
  end
end
