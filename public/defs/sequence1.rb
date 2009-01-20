
class Sequence1 < OpenWFE::ProcessDefinition
  description "a tiny sequence"
  sequence do
    error 'I hate that'
    participant 'team a'
    participant 'bob'
  end
end

