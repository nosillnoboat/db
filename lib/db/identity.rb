module DB
  # Gem identity information.
  module Identity
    def self.name
      "db"
    end

    def self.label
      "DB"
    end

    def self.version
      "3.1.0"
    end

    def self.version_label
      "#{label} #{version}"
    end

    def self.file_name
      ".#{name}rc"
    end
  end
end
