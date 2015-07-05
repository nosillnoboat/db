# v3.1.0 (2015-07-05)

- Removed JRuby support (no longer officially supported).
- Fixed secure gem installs (new cert has 10 year lifespan).
- Updated to Ruby 2.2.2.
- Added CLI process title support.
- Added code of conduct documentation.

# v3.0.0 (2015-01-01)

- Removed Ruby 2.0.0 support.
- Removed Rubinius support.
- Updated gemspec to use RUBY_GEM_SECURITY env var for gem certs.
- Updated to Thor+ 2.x.x.
- Added Ruby 2.2.0 support.

# v2.6.0 (2014-10-22)

- Updated to Ruby 2.1.3.
- Updated to Thor+ 1.7.x.
- Updated to Rubinius 2.2.10.
- Updated gemspec to add security keys unless in a CI environment.
- Updated Code Climate to run only if environment variable is present.
- Updated gemspec author email address.
- Added the Guard Terminal Notifier gem.
- Refactored RSpec configuration, support, and kit folders.

# v2.5.0 (2014-07-06)

- Added Code Climate test coverage support.
- Updated to Ruby 2.1.2.

# v2.4.0 (2014-04-16)

- Updated to MRI 2.1.1.
- Updated to Rubinius 2.x.x.
- Updated RSpec helper to disable GC for all specs in order to improve performance.
- Updated README with --trust-policy for secure install of gem.
- Added Rails 4.1.x support.
- Added Gemnasium support.
- Added Coveralls support.

# v2.3.0 (2014-02-15)

- Updated gemspec homepage URL to use GitHub project URL.
- Added JRuby and Rubinius VM support.

# v2.2.0 (2013-12-28)

- Fixed Ruby Gem certificate requirements for package building.
- Fixed RSpec deprecation warnings for treating metadata symbol keys as true values.
- Fixed long-form commands to use "--" prefix. Example: --example.
- Removed UTF-8 encoding definitions - This is the default in Ruby 2.x.x.
- Removed .ruby-version from .gitignore.
- Removed Gemfile.lock from .gitignore.
- Updated to Ruby 2.1.0.
- Updated public gem certificate to be referenced from a central server.

# v2.1.0 (2013-08-13)

- Cleaned up requirement path syntax.
- Cleaned up RSpec spec definitions so that class and instance methods are described properly using . and # notation.
- Treat symbols and true values by default when running RSpec specs.
- Added .ruby-version support.
- Added pry-rescue support.
- Removed the CHANGELOG documentation from gem install.
- Updated gemspec to Thor 0.18 and higher.
- Removed excess whitespace from source code.
- Added a Versioning section to the README.
- Converted from RDoc to Markdown for documentation.
- Added previous missing LICENSE.
- Added public cert for secure install of gem.
- Switched from the pry-debugger to pry-byebug gem.
- Ignore the signing of a gem when building in a Travis CI environment.

# v2.0.0 (2013-03-17)

- Upgraded to Ruby 2.0.0.
- Added Guard support.
- Converted/detailed the CONTRIBUTING guidelines per GitHub requirements.
- Added Gem Badge support.
- Added Code Climate support.
- Switched from HTTP to HTTPS when sourcing from RubyGems.
- Added Pry development support.
- Added 'tmp' directory to .gitignore.

# v1.3.0 (2012-05-19)

- Added mention of Gemsmith gem to README.
- Updated Thor dependency to 0.x.x.
- Updated Thor+ dependency to 0.x.x.

# v1.2.0 (2012-01-29)

- Specified Thor+ 0.3.0 version dependency.
- Added Travis CI support.
- Added the spec/tmp dir to .gitignore.
- Added Ruby encoding spec to the binary.
- Switched gemspecs to listing files via Ruby code rather than shelling out to Git.
- Removed the packaging of test files.

# v1.1.0 (2012-01-02)

- Fixed bug with args, options, and config not being passed to super during CLI initialization.
- Removed the RubyGems requirement.
- Applied Gemsmith spec updates to README.
- Upgraded to Thor+ 0.2.0 and added the default_settings method.

# v1.0.0 (2011-10-29)

- Fixed typo with info output.
- Upgraded to Ruby 1.9 and added Ruby 1.9 requirements.
- Upgraded to the new Gemsmith spec.
- Removed the Utilities module and switch to using Thor+ instead.
- Removed namespace placeholder.
- Moved the basic freshen and import methods into the PG object.

# v0.4.0 (2011-07-31)

- Fixed stack dump during remigration cleanup if the generators directory didn't exist.
- Added a template for the remigration generator which provides a huge speed boost to the execution process.
- Added documentation to the remigrate generator.

# v0.3.0 (2011-07-16)

- Fixed bug with remigrate execute process where migration generator would fail to build new migrations.

# v0.2.0 (2011-07-09)

- Fixed issues with the remigration generator not merging in new migration changes and respecting order.
- Added the remigration generator and clean commands.
- Added the -F (fresh) command which aids in building a new database (including migration and seeding).
- Added the -m (migrate) command
- Added the -i (import) command.
- Renamed the remigration revert command to restore.
- Renamed the -R (remigrate) command to -M.
- Renamed the archive file to archive.dump instead of database.dump.
- Cleaned up all documentation.

# v0.1.0 (2011-07-05)

- Initial version.
