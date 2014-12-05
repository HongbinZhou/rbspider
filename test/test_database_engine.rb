require_relative "db_engine"

ret = ParserResult.new
ret.database_to_save = "test.db"
ret.table_to_save = "test"
ret["ab"] = "AB"

include DatabaseEngine
DatabaseEngine.save(ret)
