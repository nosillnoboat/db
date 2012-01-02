require "yaml"
require "thor"
require "thor/actions"
require "thor_plus/actions"

module DB
  class CLI < Thor
    include Thor::Actions
    include ThorPlus::Actions
    
    # Initialize.
    def initialize args = [], options = {}, config = {}
      super args, options, config
      @settings_file = File.join ENV["HOME"], ".db", "settings.yml"
      @settings = load_yaml default_settings
      load_database_client
    end
    
    # Overrides Thor's default source root.
    def self.source_root
      File.expand_path '.'
    end
    
    desc "-c, [create]", "Create new database."
    map "-c" => :create
    def create overrides = []
      @current_database.create overrides
      info "Database created."
    end

    desc "-D, [drop]", "Drop current database."
    map "-D" => :drop
    def drop overrides = []
      if yes? "All data in current database will be completely destroyed. Continue? (y/n)"
        @current_database.drop overrides
        info "Database dropped."
      else
        info "Database drop aborted."
      end
    end

    desc "-d, [dump]", "Dump current database to archive file."
    map "-d" => :dump
    def dump overrides = []
      @current_database.dump overrides
      info "Archive created: #{@current_database.archive_file}"
    end

    desc "-r, [restore]", "Restore current database from archive file."
    map "-r" => :restore
    def restore overrides = []
      if yes? "All data in current database will be completely overwritten. Continue? (y/n)"
        @current_database.restore overrides
        info "Database restored."
      else
        info "Database restore aborted."
      end
    end

    desc "-F, [fresh]", "Create fresh (new) database from scratch (i.e. drop, create, migrate, and seed)."
    map "-F" => :fresh
    def fresh overrides = []
      if yes? "The current database will be completely destroyed and rebuilt from scratch. Continue? (y/n)"
        @current_database.freshen
        info "Database restored."
      else
        info "Database restore aborted."
      end
    end
    
    desc "-i, [import]", "Import archive data into current database (i.e. drop, create, restore, and migrate)."
    map "-i" => :import
    def import
      if yes? "All data in current database will be completely overwritten. Continue? (y/n)"
        if File.exist? @current_database.archive_file
          @current_database.import
          info "Database import complete."
        else
          error "Import aborted. Unable to find archive file: #{@current_database.archive_file}."
        end
      else
        info "Database import aborted."
      end
    end

    desc "-m, [migrate]", "Execute migrations for current database."
    map "-m" => :migrate
    def migrate
      @current_database.migrate
      info "Database migrated."
    end

    desc "-M, [remigrate]", "Rebuild current database from new migrations."
    map "-M" => :remigrate
    method_option :setup, aliases: "-s", desc: "Prepare existing migrations for remigration process.", type: :boolean, default: false
    method_option :generator, aliases: "-g", desc: "Create the remigration generator based on new migrations (as created during setup).", type: :boolean, default: false
    method_option :execute, aliases: "-e", desc: "Execute the remigration process.", type: :boolean, default: false
    method_option :clean, aliases: "-c", desc: "Clean excess remigration files created during the setup and generator steps.", type: :boolean, default: false
    method_option :restore, aliases: "-r", desc: "Revert database migrations to original state (i.e. reverses setup).", type: :boolean, default: false
    def remigrate
      say
      case
      when options[:setup] then @current_database.remigrate_setup
      when options[:generator] then @current_database.remigrate_generator
      when options[:execute] then @current_database.remigrate_execute
      when options[:clean] then @current_database.remigrate_clean
      when options[:restore] then @current_database.remigrate_restore
      else help("remigrate")
      end
      say
    end

    desc "-e, [edit]", "Edit gem settings in default editor (assumes $EDITOR environment variable)."
    map "-e" => :edit
    def edit
      info "Launching editor..."
      `$EDITOR #{@settings_file}`
      info "Editor launched."
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
    
    # Creates default settings.
    def default_settings
      @settings = {
        current_database: PG.id,
        databases: {
          pg: {
            options: {
              create: "-w",
              drop: "-w",
              dump: "-Fc -w",
              restore: "-O -w"
            },
            archive_file: "db/archive.dump"
          }
        },
        rails: {
          enabled: true,
          env: "development"
        }
      }
    end
    
    # Loads the database client based off current database selection. At the moment, only the PostgreSQL database
    # is supported.
    def load_database_client
      @current_database = case @settings[:current_database]
      when PG.id
        PG.new self, @settings
      end
    end
  end
end
