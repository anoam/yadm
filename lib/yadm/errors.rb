module Yadm
  AlreadyRegistered = Class.new(StandardError)
  UnknownEntity = Class.new(StandardError)

  ConfigIncorrect = Class.new(StandardError)
  ConfigNotFound = Class.new(StandardError)
end
