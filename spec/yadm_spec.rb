require "spec_helper"

RSpec.describe Yadm do
  it "has a version number" do
    expect(Yadm::VERSION).not_to be nil
  end

  describe "#load_yaml" do

    it "returns exemplar of Manager" do
      _define_test_constants
      expect(Yadm.load_yaml("spec/test_data/correct.yml")).to be_a(Yadm::Manager)
      _clear_test_constants
    end

    it "loads correct config" do
      _define_test_constants

      manager = Yadm.load_yaml("spec/test_data/correct.yml")

      expect(manager.resolve(:foo)).to be_a(Foo)
      expect(manager.resolve(:bar)).to be_a(Bar)
      expect(manager.resolve(:bar).foo).to be_a(Foo)
      expect(manager.resolve(:baz)).to be_a(Bar::Baz)

      _clear_test_constants
    end

    it "fails if config includes undefined classes" do
      expect{Yadm.load_yaml("spec/test_data/correct.yml")}.to raise_error(Yadm::ConfigIncorrect)
    end

    it "fails on incorrect config" do
      expect{ Yadm.load_yaml("spec/test_data/incorrect.yml") }.to raise_error(Yadm::ConfigIncorrect)
    end

    it "fails if config is missed" do
      expect{ Yadm.load_yaml("spec/test_data/missed.yml") }.to raise_error(Yadm::ConfigNotFound)
    end
  end

  def _define_test_constants
    Object.const_set(:Foo, Class.new)
    Object.const_set(:Bar, Struct.new(:foo))
    Bar.const_set(:Baz, Class.new)
  end

  def _clear_test_constants
    Bar.send(:remove_const, :Baz)
    Object.send(:remove_const, :Foo)
    Object.send(:remove_const, :Bar)
  end

end
