
= Ruote-Web2

Ruote (OpenWFEru) is an open source Ruby workflow and [incidentally] BPM engine.

Ruote-Web2 is a Ruby on Rails web application wrapping an instance of Ruote and a worklist.


Warning : this project is in a really early stage !


== getting it

prerequesite : Rails 2.1.2+

This sequence of commands will install ruote-web2 in your current directory (under ruote-web2/)

  git clone git://github.com/jmettraux/ruote-web2.git
  cd ruote-web2
  rake submodule:update
  rake ruote:install
  
  mysql -u root -e 'create database rw2_development'
  rake db:migrate
  rake data:populate

Note that "rake ruote:install" will install the source of Ruote and its dependencies under vendor/plugins/ruote_plugin/lib_ruote/ (and try to sudo install two gems (will ask for your password)).
You could run "rake ruote:gem_install" instead to install Ruote and its dependencies as gems.


== running it

  cd ruote-web2
  ruby script/server

head to http://localhost:3000, login as admin (password 'admin').

