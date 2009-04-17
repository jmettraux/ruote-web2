
if RuotePlugin.ruote_engine
  # only enter this block if the engine is running

  # This is a test participant
  #
  # Feel free to comment it out / erase it
  #
  RuotePlugin.ruote_engine.register_participant 'herr_murphy' do |workitem|
    raise "dead beef !"
  end
end

