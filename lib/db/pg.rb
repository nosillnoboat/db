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

    # Sets up existing database migrations for remigration. Example:
    # def remigrate
    #  generate "migration", "create_posts"
    #  generate "migration", "create_pages"
    #  ...
    # end
    def remigrate_setup
      @cli.say_info "Setting up project for remigration..."
      # Initialize.
      migrate_path = File.join("db", "migrate")
      # Create migration "old" (for backup) and "new" (for modification) directories.
      @cli.directory migrate_path, File.join("db", "migrate-old")
      @cli.directory migrate_path, File.join("db", "migrate-new")
      # Empty the existing "migrate" directory.
      @cli.remove_file migrate_path
      @cli.empty_directory migrate_path
      # Generate a "remigrate" generator that builds new migration sequences from existing migrations. Example:
      @cli.run "rails generate generator remigrate"
      @cli.insert_into_file File.join("lib", "generators", "remigrate", "remigrate_generator.rb"), :after => "source_root File.expand_path('../templates', __FILE__)\n" do
        template = "  def remigrate\n"
        migrations = Dir.glob File.join("db", "migrate-new", "*create*.rb")
        migrations = migrations.map {|file| ["    generate", "\"migration\",", "\"#{File.basename(file).gsub(/\d+_/, '')}\""].join(' ')  + "\n"}
        template << migrations.join('')
        template << "  end\n"
      end
      @cli.say_info "Database remigration setup complete."
    end
    
    # Executes the remigration process which dumps, drops, creates, migrates, and restores (data only) the database.
    def remigrate_execute
      @cli.say_info "Remigrating the database..."
      dump
      drop
      create
      @cli.run "rake db:migrate"
      restore "-a -O -w"
      @cli.remove_file archive_file
      @cli.say_info "Remigration complete."
    end

    # Reverts all remigration setup changes.
    def remigrate_revert
      @cli.say_info "Reverting all remigration changes..."
      @cli.directory File.join("db", "migrate-old"), File.join("db", "migrate")
      @cli.remove_dir File.join("db", "migrate-old")
      @cli.remove_dir File.join("db", "migrate-new")
      generators_path = File.join "lib", "generators"
      @cli.remove_dir File.join(generators_path, "remigrate")
      @cli.remove_dir File.join(generators_path) if Dir.entries(generators_path) - %w{. ..}
      @cli.remove_dir File.join("lib", "generators")
      @cli.say_info "Remigration revert complete - Database migrations restored to original state."
    end

    private

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
