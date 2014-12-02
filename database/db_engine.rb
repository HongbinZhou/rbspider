require "active_record"

class ParserResult < Hash
  attr_accessor :database_to_save
  attr_accessor :table_to_save
end

module DatabaseEngine
  def self.save(object)
    if object.respond_to?("database_to_save") && object.respond_to?("table_to_save")
      if table_exists?(object.database_to_save, object.table_to_save + 's')
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
        setup_table(object.database_to_save, object.table_to_save + 's', object.keys)
        begin
          Kernel.const_get(object.table_to_save.capitalize + 's').new(object).save!
        rescue
          if Kernel.const_set(object.table_to_save.capitalize + 's', Class.new(ActiveRecord::Base)).new(object).save!
            puts "Info: object"
          else
            puts "Error: object saved failed"
          end
        end
      end
    else
      raise "Exception: Cannot save your object, make sure your object is inherited from ParserResult"
    end
  end

  private
  def activerecord_class_exist?(class_name)
    begin
      Kernel.const_get(class_name)
      return true
    rescue Exception => e
      puts e.message
      return false
    end
  end

  def table_exists?(db_name, table_name)
    if connect_db(db_name)
      ActiveRecord::Base.connection.table_exists? "#{table_name}"
    end
  end

  def setup_table(db_name, table_name, columns)
    if db_name && table_name && columns.length > 0
      if connect_db(db_name)
        ActiveRecord::Schema.define do
          create_table :"#{table_name}" do |table|
            columns.each do |column_name|
              table.column "#{column_name}", "text"
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

  def connect_db(db_name)
    ActiveRecord::Base.establish_connection(:adapter => "sqlite3",
                                            :database => "#{db_name}")
  end
end
