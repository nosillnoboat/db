module DB
  module Identity
    def self.name
      "db"
    end

    def self.label
      "DB"
    end

    def self.version
      "3.0.0"
    end

    def self.label_version
      [label, version].join " "
    end
  end
end
