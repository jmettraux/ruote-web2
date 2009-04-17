
= Ruote-Web2


WARNING : ruote, as a workflow engine, currently relies heavily on threading. So a multiprocess deployment target is not OK. Passenger is not OK either.


Ruote (OpenWFEru) is an open source Ruby workflow and [incidentally] BPM engine.

Ruote-Web2 is a Ruby on Rails web application wrapping an instance of Ruote and a worklist.


WARNING : this project is in a really early stage !


== getting it

prerequesite : Rails 2.3.2

  sudo gem install rails rack actionpack activerecord activeresource activesupport --no-ri --no-rdoc --source http://gems.rubyonrails.org

Make sure to have git at version 1.6+ as well.


This sequence of commands will install ruote-web2 in your current directory (under ruote-web2/)

  git clone git://github.com/jmettraux/ruote-web2.git
  cd ruote-web2

  git submodule init
  git submodule update

  sudo rake gems:install
  rake ruote:install
  
  mysql -u root -e 'create database rw2_development CHARACTER SET utf8 COLLATE utf8_general_ci'
  rake db:migrate
  rake data:populate

Note that "rake ruote:install" will install the source of Ruote and its dependencies under vendor/plugins/ruote_plugin/lib_ruote/ (and try to sudo install two gems (will ask for your password)).
You could run "rake ruote:gem_install" instead to install Ruote and its dependencies as gems.


If you have trouble with rubygems 1.3.1 on debian/ubuntu, the comments there might help :

  http://intertwingly.net/blog/2008/11/23/RubyGems-1-3-1-on-Ubuntu-8-10


== running it

  cd ruote-web2
  ruby script/server

head to http://localhost:3000, login as admin (password 'admin').

