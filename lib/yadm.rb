require_relative "yadm/version"
require_relative "yadm/manager"
require_relative "yadm/lambda_container"
require_relative "yadm/simple_container"
require_relative "yadm/storage"
require_relative "yadm/errors"
require "yaml"

module Yadm
  # Creates and fills container using YAML config.
  #   Config should contain array at root. Each element includes:
  #   - `name` (required) - identifier fo further object resolving;
  #   - `class` (required) - object class;
  #   - `dependencies` (can be skipped) - array of identifiers to resolve dependencies.
  # @param filename [String]
  # @return [Yadm::Manager]
  # @raise [Yadm::ConfigIncorrect] if config file is incorrect
  # @raise [Yadm::ConfigNotFound] if config file is not accessible
  def self.load_yaml(filename)
    entries = YAML.load(File.read(filename))
    raise(ConfigIncorrect) unless entries.is_a?(Array)

    manager = Manager.new

    entries.each do |entry|
      raise(ConfigIncorrect) unless entry.is_a?(Hash)
      raise(ConfigIncorrect) unless entry.key?("name")
      raise(ConfigIncorrect) unless entry.key?("class")
      raise(ConfigIncorrect) unless Object.const_defined?(entry["class"])

      dependencies = entry["dependencies"] || []

      manager.register(entry["name"]) do

        Object.const_get(entry["class"]).new(
          *dependencies.map{ |dependency| manager.resolve(dependency) }
        )

      end
    end

    manager
  rescue Errno::ENOENT
    raise(ConfigNotFound)
  end
end
