module DB
  # Adds Ruby on Rails support and common functionality for use with the various database clients.
  module Rails
    # Answers the current Ruby on Rails environment setting.
    def rails_env
      @settings[:rails][:env]
    end

    # Answers whether Ruby on Rails (i.e. the database.yml settings) is enabled for use.
    def rails_enabled?
      @settings[:rails][:enabled]
    end

    # Answers the Ruby on Rails database settings (i.e. database.yml) for the current Ruby on Rails environment.
    def rails_database_env_settings
      @rails_database_settings[rails_env]
    end

    # Loads the Ruby on Rails database settings (i.e. database.yml). If the database settings can't be found or are
    # improperly formated then Ruby on Rails support is disabled.
    def load_rails_database_settings
      @rails_database_settings = {}
      @rails_database_settings_file = File.join "config", "database.yml"
      if File.exist? @rails_database_settings_file
        begin
          @rails_database_settings = YAML.load_file @rails_database_settings_file
        rescue
          @cli.error "Invalid Rails database settings: #{@rails_database_settings_file}."
        end
      else
        @settings[:rails][:enabled] = false
      end
    end
  end
end
