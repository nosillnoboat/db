require "yaml"
require "thor"
require "thor/actions"

module DB
  class CLI < Thor
    include Thor::Actions
    include DB::Utilities
    
    # Initialize.
    def initialize args = [], options = {}, config = {}
      super
      @settings = {}
      @settings_file = File.join ENV["HOME"], ".db", "settings.yml"
      load_settings
      load_database_client
    end
    
    # Overrides Thor's default source root.
    def self.source_root
      File.expand_path '.'
    end
    
    desc "-c, [create]", "Create database."
    map "-c" => :create
    def create overrides = nil
      @current_database.create overrides
      say_info "Database created."
    end

    desc "-D, [drop]", "Drop database."
    map "-D" => :drop
    def drop overrides = nil
      if yes? "All data in current database will be completely destroyed. Continue (y/n)?"
        @current_database.drop overrides
        say_info "Database dropped."
      else
        say_info "Database drop aborted."
      end
    end

    desc "-d, [dump]", "Dump database to archive file."
    map "-d" => :dump
    def dump overrides = nil
      @current_database.dump overrides
      say_info "Database dumped."
    end

    desc "-r, [restore]", "Restore database from archive file."
    map "-r" => :restore
    def restore overrides = nil
      if yes? "All data in current database will be completely overwritten. Continue (y/n)?"
        @current_database.restore overrides
        say_info "Database restored."
      else
        say_info "Database restore aborted."
      end
    end

    desc "-R, [remigrate]", "Rebuild all database migrations and the database itself."
    map "-R" => :remigrate
    method_option :setup, :aliases => "-s", :desc => "Prepares existing migrations for remigration process.", :type => :boolean, :default => false
    method_option :execute, :aliases => "-e", :desc => "Executes the remigration process.", :type => :boolean, :default => false
    method_option :revert, :aliases => "-r", :desc => "Reverts database migrations to original state (before setup).", :type => :boolean, :default => false
    def remigrate
      say
      case
      when options[:setup] then @current_database.remigrate_setup
      when options[:execute] then @current_database.remigrate_execute
      when options[:revert] then @current_database.remigrate_revert
      else say_info("Type 'db help remigrate' for usage.")
      end
      say
    end

    desc "-e, [edit]", "Edit settings in default editor (as set via the $EDITOR environment variable)."
    map "-e" => :edit
    def edit
      say_info "Launching editor..."
      `$EDITOR #{@settings_file}`
      say_info "Editor launched."
    end

    desc "-v, [version]", "Show version."
    map "-v" => :version
    def version
      say "DB " + VERSION
    end

    desc "-h, [help]", "Show this message."
    def help task = nil
      say and super
    end

    private
    
    # Load settings.
    def load_settings
      # Defaults.
      @settings = {
        :current_database => PG.id,
        :databases => {
          :pg => {
            :options => {
              :create => "-w",
              :drop => "-w",
              :dump => "-Fc -w",
              :restore => "-O -w"
            },
            :archive_file => "db/database.dump"
          }
        },
        :rails => {
          :enabled => true,
          :env => "development"
        }
      }
      
      # Settings File - Trumps defaults.
      if File.exists? @settings_file
        begin
          settings = YAML::load_file @settings_file
          @settings.merge! settings.reject {|key, value| value.nil?}
        rescue
          say_error "Invalid settings: #{@settings_file}."
        end
      end
    end
    
    # Loads the database client based off current database selection. At the moment, only the PostgreSQL database
    # is supported.
    def load_database_client
      @current_database = case @settings[:current_database]
      when PG.id then PG.new(self, @settings)
      end
    end
  end
end
