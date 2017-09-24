require 'rspec'

RSpec.describe "Yadm::Manager" do
  let(:manager) { Yadm::Manager.new }

  describe "Simple register" do

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

    it "resolves proc" do
      l = -> { "Proc result" }
      manager.register_object(:lambda, l)
      expect(manager.resolve(:lambda)).to be_a(Proc)
      expect(manager.resolve(:lambda).call).to eq "Proc result"
    end

    it "rises error on conflict" do
      manager.register_object(:my_object, double(:object_1))
      expect { manager.register_object(:my_object, double(:object_2)) }.to raise_error(Yadm::AlreadyRegistered)
    end

    it "rises error if entity wasn't regitered" do
      expect { manager.resolve(:was_not_registered) }.to raise_error(Yadm::UnknownEntity)
    end
  end

  describe "Using block" do

    it "resolves block result" do
      obj = double(:object)

      manager.register(:my_object) do
        obj
      end

      expect(manager.resolve(:my_object)).to be obj
    end

    it "can uses previously registered objetcs" do
      obj = double(:object_1)

      manager.register_object(:first_object, obj)

      manager.register(:second_object) do |manager|
        manager.resolve(:first_object)
      end

      expect(manager.resolve(:second_object)).to be obj
    end

    it "can uses not yet registered objects" do
      obj = double(:object_1)

      manager.register(:second_object) do |manager|
        manager.resolve(:first_object)
      end

      manager.register_object(:first_object, obj)
      expect(manager.resolve(:second_object)).to be obj
    end

    it "raises error on unresolved dependency" do
      manager.register(:second_object) do |manager|
        manager.resolve(:first_object)
      end

      expect{ manager.resolve(:my_object) }.to raise_error(Yadm::UnknownEntity)
    end

    it "raises error on conflict" do
      obj_1 = double(:object_1)
      obj_2 = double(:object_2)

      manager.register_object(:object, obj_1)

      expect do
        manager.register(:object) { obj_2 }
      end.to raise_error(Yadm::AlreadyRegistered)
    end
  end

end
