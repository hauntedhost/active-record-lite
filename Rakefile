namespace :db do
  desc 'create and seed cat database'
  task :create do
    output = `sqlite3 db/cats.sqlite3 < db/seeds.sql`
  end

  namespace :test do
    desc 'create and seed test database'
    task :prepare do
      output = `sqlite3 db/test.sqlite3 < db/seeds.sql`
    end
  end
end
