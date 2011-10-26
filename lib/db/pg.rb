module DB
  # Wrapper for PostgreSQL database functionality.
  class PG
    include DB::Rails
    
    # Answers the database client ID.
    def self.id
      "pg"
    end

    # Initializes the PostgreSQL CLI client.
    # ==== Parameters
    # * +cli+ - Required. The command line interface (assumes Thor-like behavior).
    # * +settings+ - Required. The command line interface settings.
    def initialize cli, settings
      @cli = cli
      @settings = settings
      load_rails_database_settings
    end

    # Answers the default database settings.
    def default_settings
      @settings[:databases][PG.id.to_sym]
    end

    # Answers the default database options.
    def default_options
      default_settings[:options]
    end

    # Answers the archive file path.
    def archive_file
      default_settings[:archive_file]
    end

    # Creates a new database.
    def create options = []
      @cli.run "createdb #{create_options options}"
    end

    # Drops/destroys a database.
    def drop options = []
      @cli.run "dropdb #{drop_options options}"
    end

    # Dumps existing database to archive file.
    def dump options = []
      @cli.run "pg_dump #{dump_options options}"
    end
    
    # Restores a database from archive file.
    def restore options = []
      @cli.run "pg_restore #{restore_options options}"
    end

    # Executes database migrations.
    def migrate
      @cli.run "rake db:migrate"
    end
    
    # Adds any/all seed data to database.
    def seed
      @cli.run "rake db:seed"
    end

    # Rebuilds the current database by executing all migrations and adding initial seed data.
    def freshen
      drop
      create
      migrate
      seed
    end
    
    # Imports a database archive into the current database (i.e. drop, create, restore, and migrate)."
    def import
      drop
      create
      restore
      migrate
    end

    # Sets up existing database migrations for remigration.
    def remigrate_setup
      @cli.say_info "Setting up project for remigration..."
      # Initialize.
      migrate_path = File.join("db", "migrate")
      # Create an "old" migration directory (for backup purposes).
      @cli.directory migrate_path, File.join("db", "migrate-old")
      # Create a "new" migration directory (for edit/update purposes).
      @cli.directory migrate_path, File.join("db", "migrate-new")
      @cli.say_info "Database remigration setup complete."
    end
    
    # Generates a "remigrate" generator that builds new migration sequences from existing migrations (i.e. migrate-new).
    def remigrate_generator
      if File.exists? File.join("lib", "generators", "remigrate", "remigrate_generator.rb")
        if @cli.yes?("Existing generator detected. Overwrite and lose all changes? (y/n)")
          @cli.remove_dir File.join("lib", "generators", "remigrate")
          build_generator
        else
          @cli.say_info "Remigration generator aborted."
        end
      else
        build_generator
      end
    end
    
    # Executes the remigration process which dumps, drops, creates, migrates, and restores (data only) the database.
    def remigrate_execute
      @cli.say_info "Remigrating the database..."
      # Dump, drop, and recreate the database.
      dump unless File.exists?(archive_file)
      drop
      create
      # Remove existing migrations.
      migrate_path = File.join("db", "migrate")
      @cli.remove_file migrate_path
      # Execute the remigration generator to generate new but empty migrations.
      @cli.run "rails generate remigrate"
      # Execute new migrations.
      @cli.run "rake db:migrate"
      # Restores the database archive dump (data only).
      restore "-a -O -w"
      @cli.say_info "Remigration complete."
    end

    # Cleans excess remigration files created during the setup and generator steps.
    def remigrate_clean
      if @cli.yes? "Cleaning of remigration support files is non-recoverable. Continue? (y/n)"
        @cli.say_info "Cleaning excess remigration files..."
        # Remove migrations.
        @cli.remove_dir File.join("db", "migrate-old")
        @cli.remove_dir File.join("db", "migrate-new")
        # Remove generators.
        generators_path = File.join "lib", "generators"
        @cli.remove_dir File.join(generators_path, "remigrate")
        if File.exists?(generators_path) && (Dir.entries(generators_path) - %w{. ..})
          @cli.remove_dir File.join(generators_path)
        end
        # Remove archive file.
        @cli.remove_file archive_file
        @cli.say_info "Remigration cleanup complete."
      else
        @cli.say_info "Remigration cleanup aborted."
      end
    end

    # Restores remigration setup changes.
    def remigrate_restore
      @cli.say_info "Reverting all remigration changes..."
      # Remove current migrations.
      @cli.remove_dir File.join("db", "migrate")
      # Restore original migrations.
      @cli.directory File.join("db", "migrate-old"), File.join("db", "migrate")
      # Remove new and old migrations.
      @cli.remove_dir File.join("db", "migrate-old")
      @cli.remove_dir File.join("db", "migrate-new")
      # Remove generators.
      generators_path = File.join "lib", "generators"
      @cli.remove_dir File.join(generators_path, "remigrate")
      @cli.remove_dir File.join(generators_path) if Dir.entries(generators_path) - %w{. ..}
      @cli.say_info "Remigration revert complete - Database migrations restored to original state."
    end

    private
    
    # Configures and initializes options with defaults (if necessary).
    # ==== Parameters
    # * +options+ = Required. The options to configure.
    # * +defaults+ - Required. The default options if the supplied options are missing.
    def configure_options options, defaults
      options = Array options
      options = Array(defaults) if options.empty?
      options
    end
    
    # Builds remigration generator based off new migrations (i.e. db/migrate-new).
    def build_generator
      @cli.run "rails generate generator remigrate"
      generator_file = File.join "lib", "generators", "remigrate", "remigrate_generator.rb"
      @cli.template File.expand_path(File.join(File.dirname(__FILE__), "templates", "generator.rb")), generator_file, force: true
      @cli.insert_into_file generator_file, after: "def remigrate\n" do
        migrations = Dir.glob File.join("db", "migrate-new", "*.rb")
        migrations = migrations.map {|file| ["    copy_migration", "\"#{File.basename(file, '.rb').gsub(/\d+_/, '')}\""].join(' ')  + "\n"}
        migrations * ''
      end
    end

    # Builds default PostgreSQL createdb command line options.
    # ==== Parameters
    # * +options+ = Optional. Overrides the default options. Default: []
    def create_options options = []
      options = configure_options options, default_options[:create]
      if rails_enabled?
        options << "-E #{rails_database_env_settings['encoding']}"
        options << "-O #{rails_database_env_settings['username']}"
        options << "-U #{rails_database_env_settings['username']}"
        options << "-h #{rails_database_env_settings['host']}"
        options << "#{rails_database_env_settings['database']}"
      end
      options.compact * ' '
    end

    # Builds default PostgreSQL dropdb command line options.
    # ==== Parameters
    # * +options+ = Optional. Overrides the default options. Default: []
    def drop_options options = []
      options = configure_options options, default_options[:drop]
      if rails_enabled?
        options << "-U #{rails_database_env_settings['username']}"
        options << "-h #{rails_database_env_settings['host']}"
        options << "#{rails_database_env_settings['database']}"
      end
      options.compact * ' '
    end

    # Builds default PostgreSQL pg_dump command line options.
    # ==== Parameters
    # * +options+ = Optional. Overrides the default options. Default: []
    def dump_options options = []
      options = configure_options options, default_options[:dump]
      if rails_enabled?
        options << "-U #{rails_database_env_settings['username']}"
        options << "-f #{archive_file}"
        options << "#{rails_database_env_settings['database']}"
      end
      options.compact * ' '
    end

    # Builds default PostgreSQL pg_restore command line options.
    # ==== Parameters
    # * +options+ = Optional. Overrides the default options. Default: []
    def restore_options options = []
      options = configure_options options, default_options[:restore]
      if rails_enabled?
        options << "-h #{rails_database_env_settings['host']}"
        options << "-U #{rails_database_env_settings['username']}"
        options << "-d #{rails_database_env_settings['database']}"
        options << "#{archive_file}"
      end
      options.compact * ' '
    end
  end
end
