# encoding: UTF-8
require 'spec_helper'
require 'roadie/rspec'

module Roadie
  describe ProviderList do
    let(:test_provider) { TestProvider.new }
    subject(:provider) { ProviderList.new([test_provider]) }

    it_behaves_like "roadie asset provider", valid_name: "valid", invalid_name: "invalid" do
      let(:test_provider) { TestProvider.new "valid" => "" }
    end

    it "finds using all given providers" do
      first = TestProvider.new "foo.css" => "foo { color: green; }"
      second = TestProvider.new "bar.css" => "bar { color: green; }"
      provider = ProviderList.new [first, second]

      provider.find_stylesheet("foo.css").to_s.should include "foo"
      provider.find_stylesheet("bar.css").to_s.should include "bar"
      provider.find_stylesheet("baz.css").should be_nil
    end

    it "is enumerable" do
      provider.should be_kind_of(Enumerable)
      provider.should respond_to(:each)
      provider.each.to_a.should == [test_provider]
    end

    it "has a size" do
      provider.size.should == 1
    end

    it "can have providers pushed and popped" do
      other = double "Some other provider"

      expect {
        provider.push other
        provider << other
      }.to change(provider, :size).by(2)

      expect {
        provider.pop.should == other
      }.to change(provider, :size).by(-1)
    end

    it "can have providers shifted and unshifted" do
      other = double "Some other provider"

      expect {
        provider.unshift other
      }.to change(provider, :size).by(1)

      expect {
        provider.shift.should == other
      }.to change(provider, :size).by(-1)
    end

    describe "wrapping" do
      it "creates provider lists with the arguments" do
        ProviderList.wrap(test_provider).should be_instance_of(ProviderList)
        ProviderList.wrap(test_provider, test_provider).size.should == 2
      end

      it "flattens arrays" do
        ProviderList.wrap([test_provider, test_provider], test_provider).size.should == 3
        ProviderList.wrap([test_provider, test_provider]).size.should == 2
      end

      it "combines with providers from other lists" do
        other_list = ProviderList.new([test_provider, test_provider])
        ProviderList.wrap(test_provider, other_list).size.should == 3
      end

      it "returns the passed list if only a single ProviderList is passed" do
        other_list = ProviderList.new([test_provider])
        ProviderList.wrap(other_list).should eql other_list
      end
    end
  end
end
