require "rails/generators/active_record/migration"

class RemigrateGenerator < Rails::Generators::Base
  include Rails::Generators::Migration
  extend ActiveRecord::Generators::Migration

  source_root Dir.pwd

  # Generates the migrations based on migration file names listed below. It is not recommended that you rename any of these files
  # as they were sourced from the "migrate-new" folder. If adjustments are required, edit the files in the "migrate-new" folder
  # instead and then build this generator again. However, it IS recommend you rearrange the order of the migrations listed below,
  # if necessary, as the order of each migration will directly affect the new migration creation sequence.
  def remigrate
  end

  private

  def copy_migration name
    path = File.join Dir.pwd, "db", "migrate"
    number = self.class.next_migration_number path
    copy_file Dir[File.join("db", "migrate-new", "*#{name}.rb")].first, File.join(path, "#{number}_#{name}.rb")
  end
end
