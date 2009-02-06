
class Sequence1 < OpenWFE::ProcessDefinition
  description "a tiny sequence"
  sequence do
    participant 'team a'
    participant 'bob'
  end
end

