require_relative '../lib/sql_object'
require_relative '../lib/associatable.rb'

describe "AssocOptions" do
  describe "BelongsToOptions" do
    it "provides defaults" do
      options = BelongsToOptions.new("house")

      expect(options.foreign_key).to eq(:house_id)
      expect(options.class_name).to eq("House")
      expect(options.primary_key).to eq(:id)
    end

    it "allows overrides" do
      options = BelongsToOptions.new("owner", {
          :foreign_key => :human_id,
          :class_name => "Human",
          :primary_key => :human_id
        })

      expect(options.foreign_key).to eq(:human_id)
      expect(options.class_name).to eq("Human")
      expect(options.primary_key).to eq(:human_id)
    end
  end

  describe "HasManyOptions" do
    it "provides defaults" do
      options = HasManyOptions.new("cats", "Human")

      expect(options.foreign_key).to eq(:human_id)
      expect(options.class_name).to eq("Cat")
      expect(options.primary_key).to eq(:id)
    end

    it "allows overrides" do
      options = HasManyOptions.new("cats", "Human", {
          :foreign_key => :owner_id,
          :class_name => "Kitten",
          :primary_key => :human_id
        })

      expect(options.foreign_key).to eq(:owner_id)
      expect(options.class_name).to eq("Kitten")
      expect(options.primary_key).to eq(:human_id)
    end
  end

  describe "AssocOptions" do
    before(:all) do
      class Cat < SQLObject
      end

      class Human < SQLObject
        set_table_name = "humans"
      end
    end

    it "#model_class returns class of associated object" do
      options = BelongsToOptions.new("human")
      expect(options.other_class).to eq(Human)
      expect(options.other_table).to eq("humans")

      options = HasManyOptions.new("cats", "Human")
      expect(options.other_class).to eq(Cat)
      expect(options.other_table).to eq("cats")
    end
  end
end

describe "Associatable" do
  # OPTIMIZE: this before/after is terrible
  before(:each) { DBConnection.open('db/test.sqlite3') }
  after(:all) { system 'rake db:test:prepare' }

  before(:all) do
    class Cat < SQLObject
      my_attr_accessor :id, :name, :owner_id

      belongs_to :human, foreign_key: :owner_id
    end

    class Human < SQLObject
      set_table_name = "humans"

      my_attr_accessor :id, :fname, :lname, :house_id

      has_many :cats, foreign_key: :owner_id
      belongs_to :house
    end

    class House < SQLObject
      my_attr_accessor :id, :address

      has_many :humans
    end
  end

  describe "#belongs_to" do
    let(:sebastian) { Cat.find(1) }
    let(:sean) { Human.find(1) }

    it "fetches `human` from `Cat` correctly" do
      expect(sebastian).to respond_to(:human)
      human = sebastian.human

      expect(human).to be_instance_of(Human)
      expect(human.fname).to eq("Sean")
    end

    it "fetches `house` from `Human` correctly" do
      expect(sean).to respond_to(:house)
      house = sean.house

      expect(house).to be_instance_of(House)
      expect(house.address).to eq("830 Brooks Avenue")
    end
  end

  describe "#has_many" do
    let(:alli) { Human.find(2) }
    let(:venice_house) { House.find(1) }

    it "fetches `cats` from `Human`" do
      expect(alli).to respond_to(:cats)
      cats = alli.cats

      expect(cats.length).to eq(2)

      expected_cat_names = ["Esther", "Boosie"]
      2.times do |i|
        cat = cats[i]

        expect(cat).to be_instance_of(Cat)
        expect(cat.name).to eq(expected_cat_names[i])
      end
    end

    it "fetches `humans` from `House`" do
      expect(venice_house).to respond_to(:humans)
      humans = venice_house.humans

      expect(humans.length).to eq(2)
      expect(humans[0]).to be_instance_of(Human)
      expect(humans[0].fname).to eq("Sean")
    end
  end
end
