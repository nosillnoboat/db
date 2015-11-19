# DB

[![Gem Version](https://badge.fury.io/rb/db.svg)](http://badge.fury.io/rb/db)
[![Code Climate GPA](https://codeclimate.com/github/bkuhlmann/db.svg)](https://codeclimate.com/github/bkuhlmann/db)
[![Code Climate Coverage](https://codeclimate.com/github/bkuhlmann/db/coverage.svg)](https://codeclimate.com/github/bkuhlmann/db)
[![Gemnasium Status](https://gemnasium.com/bkuhlmann/db.svg)](https://gemnasium.com/bkuhlmann/db)
[![Travis CI Status](https://secure.travis-ci.org/bkuhlmann/db.svg)](http://travis-ci.org/bkuhlmann/db)
[![Patreon](https://img.shields.io/badge/patreon-donate-brightgreen.svg)](https://www.patreon.com/bkuhlmann)

A command line interface for database management with customizable options for common tasks (i.e. create, drop, dump,
restore, etc.) Also supports the remigration process which makes dealing with cleaning up tiny migration changes/updates
that accumulate over time in your Ruby on Rails db/migrate folder.

<!-- Tocer[start]: Auto-generated, don't remove. -->

# Table of Contents

- [Features](#features)
- [Requirements](#requirements)
- [Setup](#setup)
- [Usage](#usage)
  - [Remigration](#remigration)
- [Tests](#tests)
- [Versioning](#versioning)
- [Code of Conduct](#code-of-conduct)
- [Contributions](#contributions)
- [License](#license)
- [History](#history)
- [Credits](#credits)

<!-- Tocer[finish]: Auto-generated, don't remove. -->

# Features

1. Faster execution when creating/dropping databases than the default Ruby on Rails rake tasks.
2. Adds support for dumping and restoring of a database.
3. Adds configurable settings for common database operations.
4. Adds support for easier remigration/rebuilding of a database with many migration fragments.

# Requirements

0. [MRI 2.x.x](http://www.ruby-lang.org).
0. A strong understanding of database management, migrations, dumps/restores, etc.

# Setup

For a secure install, type the following from the command line (recommended):

    gem cert --add <(curl -Ls https://www.alchemists.io/gem-public.pem)
    gem install db --trust-policy MediumSecurity

NOTE: A HighSecurity trust policy would be best but MediumSecurity enables signed gem verification while
allowing the installation of unsigned dependencies since they are beyond the scope of this gem.

For an insecure install, type the following (not recommended):

    gem install db

You can change the default settings for this gem by creating the following file:

    ~/.db/settings.yml

The contents of the file should look like this (where the default values can be changed to your liking):

    ---
    :current_database: pg
    :databases:
      :pg:
        :options:
          :create: -w
          :drop: -w
          :dump: -Fc -w
          :restore: -O -w
        :archive_file: "db/archive.dump"
    :rails:
      :enabled: true
      :env: development

# Usage

From the command line, type: db

    db -D, [drop]       # Drop current database.
    db -F, [fresh]      # Create fresh (new) database from scratch (i.e. drop, create, migrate, and seed).
    db -M, [remigrate]  # Rebuild current database from new migrations.
    db -c, [create]     # Create new database.
    db -d, [dump]       # Dump current database to archive file.
    db -e, [edit]       # Edit gem settings in default editor (assumes $EDITOR environment variable).
    db -h, [help]       # Show this message.
    db -i, [import]     # Import archive data into current database (i.e. drop, create, restore, and migrate).
    db -m, [migrate]    # Execute migrations for current database.
    db -r, [restore]    # Restore current database from archive file.
    db -v, [version]    # Show version.

For more remigration options, type: db help remigrate:

    -s, [--setup]      # Prepare existing migrations for remigration process.
    -g, [--generator]  # Create the remigration generator based on new migrations (as created during setup).
    -e, [--execute]    # Execute the remigration process.
    -c, [--clean]      # Clean excess remigration files created during the setup and generator steps.
    -r, [--restore]    # Revert database migrations to original state (i.e. reverses setup).

## Remigration

For those with Ruby on Rails projects, you might find this a welcomed tool for cleaning and maintaining your
migrations. The problem with database migrations is that they tend to get cluttered over time. Instead of
nice create migrations you eventually get drop, rename, add, etc. migrations mixed with your create migrations
(think of this as migration fragmentation). This can also make your table schemas messy to read depending on
how many changes you have applied to a table over time. Instead of being stuck with this clutter, the
remigration process allows you to clean up previous migration fragments and consolidate them into create
migrations instead so that you have a directory of create migration files with a better looking database
schema to boot.

To remigrate a database:

0. Run: db -M -s
0. Remove excess migrations by manually applying changes to existing "create" migrations.
0. Run: db -M -g
0. Edit the "remigrate_generator" and reorder the migrations (if necessary, otherwise move to the next step).
0. Run: db -M -e
0. Run: db -M -c

Remigration is a multi-step process due to the fact that you need to have breakpoints where you can customize
and tweak your migrations as necessary. You'll want to perform all six steps each time you undergo remigration.
Should you get cold feet and decide against remigration, run the following command to restore to original state:

    db -M -r

# Tests

To test, run:

    bundle exec rspec spec

# Versioning

Read [Semantic Versioning](http://semver.org) for details. Briefly, it means:

- Patch (x.y.Z) - Incremented for small, backwards compatible bug fixes.
- Minor (x.Y.z) - Incremented for new, backwards compatible public API enhancements and/or bug fixes.
- Major (X.y.z) - Incremented for any backwards incompatible public API changes.

# Code of Conduct

Please note that this project is released with a [CODE OF CONDUCT](CODE_OF_CONDUCT.md). By participating in this project
you agree to abide by its terms.

# Contributions

Read [CONTRIBUTING](CONTRIBUTING.md) for details.

# License

Copyright (c) 2011 [Alchemists](https://www.alchemists.io).
Read the [LICENSE](LICENSE.md) for details.

# History

Read the [CHANGELOG](CHANGELOG.md) for details.
Built with [Gemsmith](https://github.com/bkuhlmann/gemsmith).

# Credits

Developed by [Brooke Kuhlmann](https://www.alchemists.io) at [Alchemists](https://www.alchemists.io)
