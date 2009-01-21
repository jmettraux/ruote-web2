
namespace :data do

  require 'active_record'
  require 'active_record/fixtures'

  #
  # Populates the development database with the data found under db/dev_fixtures
  #
  #   rake data:populate
  #
  task :populate => :environment do

    Fixtures.create_fixtures(
      'db/dev_fixtures',
      %w{ users groups user_groups definitions group_definitions })

    puts
    puts "loaded #{User.find(:all).size} users"
    puts "loaded #{Group.find(:all).size} groups"
    puts "loaded #{UserGroup.find(:all).size} user<->group"
    puts "loaded #{Definition.find(:all).size} definitions"
    puts "loaded #{GroupDefinition.find(:all).size} group<->definition"
    puts
  end

  ##
  ## Bootstraps the development database for ruote-web
  ##
  ##   rake data:bootstrap
  ##
  #task :bootstrap do

  #  db = 'rw2_development'
  #  db_admin_user = 'root'
  #  db_user = 'densha'

  #  sh "mysql -u #{db_admin_user} -p -e \"drop database if exists #{db}\""
  #  sh "mysql -u #{db_admin_user} -p -e \"create database #{db} CHARACTER SET utf8 COLLATE utf8_general_ci\""
  #  sh "mysql -u #{db_admin_user} -p -e \"grant all privileges on #{db}.* to '#{db_user}'@'localhost' identified by '#{db_user}'\""

  #  rm_rf [ 'work_test', 'work_development' ]
  #  sh 'rm log/*.log'
  #  touch 'log/development.log'
  #end
end

