require_relative '../lib/mass_object'

describe MassObject do
  before(:all) do
    class EmptyMassObject < MassObject
    end

    class MyMassObject < MassObject
      my_attr_accessor :x, :y
    end
  end

  it '::attributes starts out empty' do
    expect(EmptyMassObject.attributes).to be_empty
  end

  it '::my_attr_accessible sets self.attributes' do
    expect(MyMassObject.attributes).to eq([:x, :y])
  end

  it '#initialize performs mass-assignment' do
    obj = MyMassObject.new(x: 'xxx', y: 'yyy')

    expect(obj.x).to eq('xxx')
    expect(obj.y).to eq('yyy')
  end

  it '#initialize accepts string keys' do
    obj = MyMassObject.new('x' => 'xxx', 'y' => 'yyy')

    expect(obj.x).to eq('xxx')
    expect(obj.y).to eq('yyy')
  end

  it '#initialize rejects unregistered keys' do
    expect {
      obj = MyMassObject.new(z: 'zzz')
    }.to raise_error("mass assignment to unregistered attribute 'z'")
  end
end
