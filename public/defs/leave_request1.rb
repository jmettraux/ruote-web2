
#
# an example of a Ruby process definition, for a small
# leave request application.
#
class LeaveRequest1 < OpenWFE::ProcessDefinition

  description "requesting some time off"

  #
  # setting some fields and variables right at the beginning of the
  # process

  #
  # setting some "aliases" : the process definition won't mention
  # users by their login names directly, but by their function

  set :v => "employee", :value => "${launcher}"
  set :v => "boss", :value => "alice"
  set :v => "assistant", :value => "bob"

  #
  # the 'body' of the process definition
  #
  sequence do

    #
    # the first participant is the employee (the user who
    # launched the process)
    #
    employee

    #
    # now setting some fields that the assistant and perhaps
    # the boss will fill.
    #
    set :f => "granted", :value => "false"
    set :f => "not_enough_info", :value => "false"
    set :f => "boss_should_have_a_look", :value => "false"

    assistant

    #
    # if the assistant set the field 'boss_should_have_a_look',
    # then the process will head to the boss desk
    #
    boss :if => "${f:boss_should_have_a_look}"

    #
    # employee gets the answer to his request
    #
    employee
  end
end

