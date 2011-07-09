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

    # Answers the archive file (including path).
    def archive_file
      default_settings[:archive_file]
    end

    # Creates a new database.
    def create options = nil
      @cli.run "createdb #{create_options options.to_a}"
    end

    # Drops/destroys a database.
    def drop options = nil
      @cli.run "dropdb #{drop_options options.to_a}"
    end

    # Dumps existing database to an archive file.
    def dump options = nil
      @cli.run "pg_dump #{dump_options options.to_a}"
    end
    
    # Restores a database from an archive file.
    def restore options = nil
      @cli.run "pg_restore #{restore_options options.to_a}"
    end

    # Executes database migrations.
    def migrate
      if rails_enabled?
        @cli.run "rake db:migrate"
      else
        @cli.say_error "Unable to migrate - This is not a Rails project or Rails support is not enabled."
      end
    end
    
    # Adds any/all seed data to database.
    def seed
      if rails_enabled?
        @cli.run "rake db:seed"
      else
        @cli.say_error "Unable to migrate - This is not a Rails project or Rails support is not enabled."
      end
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
      @cli.empty_directory migrate_path
      # Execute the remigration generator.
      migrate
      # Copy over migration file details from migrate-new to migrate folder based on migration base names.
      Dir[File.join("db", "migrate-new", "*.rb")].each do |file|
        name = File.basename(file).gsub(/\d+_/, '')
        old_file = Dir[File.join("db", "migrate-new", "*#{name}")].first
        new_file = Dir[File.join("db", "migrate", "*#{name}")].first
        @cli.copy_file old_file, new_file, :force => true
      end
      # Execute new migrations.
      @cli.run "rake db:migrate"
      # Restores the database archive dump (data only).
      restore "-a -O -w"
      @cli.say_info "Remigration complete."
    end

    # Cleans excess remigration files created during the setup and generator steps.
    def remigrate_clean
      if @cli.yes? "Cleaning of remigration support files is non-recoverable. Continue? (y/n)"
        @cli.say_info "Cleaning up excess remigration files..."
        # Remove migrations.
        @cli.remove_dir File.join("db", "migrate-old")
        @cli.remove_dir File.join("db", "migrate-new")
        # Remove generators.
        generators_path = File.join "lib", "generators"
        @cli.remove_dir File.join(generators_path, "remigrate")
        @cli.remove_dir File.join(generators_path) if Dir.entries(generators_path) - %w{. ..}
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
    
    # Builds remigration generator based off new migrations (i.e. db/migrate-new).
    def build_generator
      @cli.run "rails generate generator remigrate"
      @cli.insert_into_file File.join("lib", "generators", "remigrate", "remigrate_generator.rb"), :after => "source_root File.expand_path('../templates', __FILE__)\n" do
        template = "  def remigrate\n"
        migrations = Dir.glob File.join("db", "migrate-new", "*.rb")
        migrations = migrations.map {|file| ["    generate", "\"migration\",", "\"#{File.basename(file, '.rb').gsub(/\d+_/, '')}\""].join(' ')  + "\n"}
        template << migrations.join('')
        template << "  end\n"
      end
    end

    # Builds default PostgreSQL createdb command line options.
    # ==== Parameters
    # * +options+ = Optional. Overrides the default options.
    def create_options options = []
      options = [default_options[:create]] if options.empty?
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
    # * +options+ = Optional. Overrides the default options.
    def drop_options options = []
      options = [default_options[:drop]] if options.empty?
      if rails_enabled?
        options << "-U #{rails_database_env_settings['username']}"
        options << "-h #{rails_database_env_settings['host']}"
        options << "#{rails_database_env_settings['database']}"
      end
      options.compact * ' '
    end

    # Builds default PostgreSQL pg_dump command line options.
    # ==== Parameters
    # * +options+ = Optional. Overrides the default options.
    def dump_options options = []
      options = [default_options[:dump]] if options.empty?
      if rails_enabled?
        options << "-U #{rails_database_env_settings['username']}"
        options << "-f #{archive_file}"
        options << "#{rails_database_env_settings['database']}"
      end
      options.compact * ' '
    end

    # Builds default PostgreSQL pg_restore command line options.
    # ==== Parameters
    # * +options+ = Optional. Overrides the default options.
    def restore_options options = []
      options = [default_options[:restore]] if options.empty?
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
