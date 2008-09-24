
#
# tasks for managing git submodules
#
namespace :submodule do

  desc(
    "performs a 'git submodule init' then 'git module update' to make sure "
    "that the vendor/plugins/ruote_plugin is loaded correctly")
  task :update do
    sh 'git submodule init'
    sh 'git submodule update'
    puts '.. vendor/plugins/ruote_plugin ready'
  end
end

