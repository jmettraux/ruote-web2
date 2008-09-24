
= Ruote-Web2

Ruote (OpenWFEru) is an open source Ruby workflow and BPM engine.

Ruote-Web2 is a Ruby on Rails web application wrapping an instance of Ruote and a worklist.


Warning : this project is in a really early stage !


== getting it

prerequesite : Rails 2.1.1+

This sequence of commands will install ruote-web2 in your current directory (under ruote-web2/)

  git clone git://github.com/jmettraux/ruote-web2.git
  cd ruote-web2
  rake submodule:update
  rake ruote:install
  rake db:migrate
  rake data:populate

== running it

  cd ruote-web2
  ruby script/server

head to http://localhost:3000, login as admin (password 'admin').

