# SqliteExperiments

## How I Did It (My Amazing Journey)

Add to `mix.exs`:

```
{:ecto, "~> 3.7"},
{:ecto_sqlite3, "~> 0.7.1"},
```

Run:

```
mix deps.get
mix ecto
mix ecto.gen.repo -r SqliteExperiments.Repo
```

Add this to suprvision tree:

```
{SqliteExperiments.Repo, []}
```

Update config.exs:

```
config :sqlite_experiments,
  ecto_repos: [SqliteExperiments.Repo]

config :sqlite_experiments, SqliteExperiments.Repo,
  database: "database.sqlite3"
```

Create firmware:

```
mix firmware
```

Make sure it works by running this code on the target:

```
alias SqliteExperiments.Repo
alias SqliteExperiments.Person
path = Application.app_dir(:sqlite_experiments, "priv/repo/migrations")
Ecto.Migrator.run(Repo, path, :up, all: true)

# This should work / not crash:
Repo.all(Person)
```
