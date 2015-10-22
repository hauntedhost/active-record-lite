require_relative '../lib/sql_object'

describe Searchable do
  # OPTIMIZE: this before/after is terrible
  before(:each) { DBConnection.open('db/test.sqlite3') }
  after(:all) { system 'rake db:test:prepare' }

  before(:all) do
    class Cat < SQLObject
      my_attr_accessor :id, :name, :owner_id
    end

    class Human < SQLObject
      set_table_name 'humans'

      my_attr_accessor :id, :fname, :lname, :house_id
    end
  end

  it '#where searches with single criterion' do
    cats = Cat.where(name: 'Sebastian')
    cat = cats.first

    expect(cats.length).to eq(1)
    expect(cat.name).to eq('Sebastian')
  end

  it '#where can return multiple objects' do
    humans = Human.where(house_id: 1)
    expect(humans.length).to eq(2)
  end

  it '#where searches with multiple criteria' do
    humans = Human.where(fname: 'Sean', house_id: 1)
    expect(humans.length).to eq(1)

    human = humans[0]
    expect(human.fname).to eq('Sean')
    expect(human.house_id).to eq(1)
  end
end
