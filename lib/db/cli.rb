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
    
    desc "-c, [create]", "Create new database."
    map "-c" => :create
    def create overrides = nil
      @current_database.create overrides
      say_info "Database created."
    end

    desc "-D, [drop]", "Drop current database."
    map "-D" => :drop
    def drop overrides = nil
      if yes? "All data in current database will be completely destroyed. Continue (y/n)?"
        @current_database.drop overrides
        say_info "Database dropped."
      else
        say_info "Database drop aborted."
      end
    end

    desc "-d, [dump]", "Dump current database to archive file."
    map "-d" => :dump
    def dump overrides = nil
      @current_database.dump overrides
      say_info "Archive created: #{@current_database.archive_file}"
    end

    desc "-r, [restore]", "Restore current database from archive file."
    map "-r" => :restore
    def restore overrides = nil
      if yes? "All data in current database will be completely overwritten. Continue (y/n)?"
        @current_database.restore overrides
        say_info "Database restored."
      else
        say_info "Database restore aborted."
      end
    end

    desc "-F, [fresh]", "Create a fresh database from scratch (i.e. drop, create, migrate, and seed)."
    map "-F" => :fresh
    def fresh overrides = nil
      if yes? "The current database will be completely destroyed and rebuilt from scratch. Continue (y/n)?"
        @current_database.drop
        @current_database.create
        @current_database.migrate
        @current_database.seed
        say_info "Database restored."
      else
        say_info "Database restore aborted."
      end
    end
    
    desc "-m, [migrate]", "Executes migrations for current database."
    map "-m" => :migrate
    def migrate
      @current_database.migrate
      say_info "Database migrated."
    end

    desc "-M, [remigrate]", "Rebuild current database migrations and the database itself."
    map "-M" => :remigrate
    method_option :setup, :aliases => "-s", :desc => "Prepares existing migrations for remigration process.", :type => :boolean, :default => false
    method_option :generator, :aliases => "-g", :desc => "Creates the remigration generator based on new migrations (produced during setup).", :type => :boolean, :default => false
    method_option :execute, :aliases => "-e", :desc => "Executes the remigration process.", :type => :boolean, :default => false
    method_option :clean, :aliases => "-c", :desc => "Cleans excess remigration files created during the setup and generator steps.", :type => :boolean, :default => false
    method_option :restore, :aliases => "-r", :desc => "Reverts database migrations to original state (i.e. reverses setup).", :type => :boolean, :default => false
    def remigrate
      say
      case
      when options[:setup] then @current_database.remigrate_setup
      when options[:generator] then @current_database.remigrate_generator
      when options[:execute] then @current_database.remigrate_execute
      when options[:clean] then @current_database.remigrate_clean
      when options[:restore] then @current_database.remigrate_restore
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
