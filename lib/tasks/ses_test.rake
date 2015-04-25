namespace :ses do
  task :test_data  => :environment do
    raise 'Error, can be only run under TEST environment' if Rails.env != 'test'
    Rake::Task['db:drop'].invoke
    Rake::Task['db:create'].invoke
    Rake::Task['db:migrate'].invoke

    puts 'Seeding db with test data ...'
    Rake::Task['db:seed:test-data'].invoke
  end
end