require 'rspec'

RSpec.describe "Yadm::Manager" do
  let(:manager) { Yadm::Manager.new }

  it "stores object" do
    obj = double(:object)
    manager.register_object(:my_object, obj)

    expect(manager.resolve(:my_object)).to be obj
  end

  it "stores two objects" do
    obj_1 = double(:object_1)
    obj_2 = double(:object_2)

    manager.register_object(:first_object, obj_1)
    manager.register_object(:second_object, obj_2)

    expect(manager.resolve(:first_object)).to be obj_1
    expect(manager.resolve(:second_object)).to be obj_2
  end

  it "resolves nil when not registered" do
    expect(manager.resolve(:was_not_registered)).to be_nil
  end

  it  "rises error on conflict" do
    manager.register_object(:my_object, double(:object_1))
    expect { manager.register_object(:my_object, double(:object_2)) }.to raise_error(Yadm::AlreadyRegistered)
  end
end
