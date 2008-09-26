
class Sequence1 < OpenWFE::ProcessDefinition
  description "a tiny sequence"
  sequence do
    participant 'alice'
    participant 'bob'
  end
end

