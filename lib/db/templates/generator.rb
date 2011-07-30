require "rails/generators/active_record/migration"

class RemigrateGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  extend ActiveRecord::Generators::Migration

  source_root Dir.pwd

  private
  
  def copy_migration name
    path = File.join Dir.pwd, "db", "migrate"
    number = self.class.next_migration_number path
    copy_file Dir[File.join("db", "migrate-new", "*#{name}.rb")].first, File.join(path, "#{number}_#{name}.rb")
  end
end
