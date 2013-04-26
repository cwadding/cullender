require 'spec_helper'

describe "Cullender::Controllers::FilterLogic" do

  before(:each) do
    @object = Object.new
    @object.extend(Cullender::Controllers::FilterLogic)
  end


        def add_or_filter(key, params, field, should_raise = false)
          if params.present? && params.has_key?(key)
            if should_raise
              params[key] = {1 => params[key], 2 => add_operator(field)}
            else
              idx = params[key].keys.last.to_i + 1
              params[key].deep_merge!({idx => add_operator(field)})
            end
          else
            if should_raise
              params[key] = add_operator(field)
            else
              params[key] = add_operator(field)
            end
          end
        end
  describe "#add_or_filter" do
    context "with filter(s) defined" do
      context "OR with the base" do
        context "with only one group" do
          before(:each) do
            @hash = {"f" => {"some_field" => {"o" => nil}}}
            @object.add_or_filter("f", @hash, "new_field", true)
          end        
          it "moves the existing group to a higher level" do
            @hash["f"].should have_key(1)
            @hash["f"][1].should have_key("some_field")
          end
          it "adds the filter to a new group" do
            @hash["f"].should have_key(2)
            @hash["f"][2].should have_key("new_field")
          end
        end
        context "with many groups" do
          before(:each) do
            @hash = {"f" => {1 => {"some_field1" => {"o" => nil}}, 2 => {"some_field2" => {"o" => nil}}}}
            @object.add_or_filter("f", @hash, "new_field", true)
          end
          it "moves the existing group to a higher level" do
            @hash["f"].should have_key(1)
            @hash["f"][1][1].should have_key("some_field1")
            @hash["f"][1][2].should have_key("some_field2")
          end
          it "adds the filter to a new group" do
            @hash["f"].should have_key(2)
            @hash["f"][2].should have_key("new_field")
          end
        end
      end
      context "OR with other groups at the same level" do
        before(:each) do
          @hash = {"f" => {1 => {"some_field1" => {"o" => nil}}, 2 => {"some_field2" => {"o" => nil}}}}
          @object.add_or_filter("f", @hash, "new_field", false)
        end
        it "keeps the existing group at the higher level" do
          @hash["f"].should have_key(1)
          @hash["f"][1].should have_key("some_field1")
          @hash["f"][2].should have_key("some_field2")
        end
        it "adds the filter to as a new group" do
          @hash["f"].should have_key(3)
          @hash["f"][3].should have_key("new_field")
        end   
      end
    end
    context "with filter(s) undefined" do
      before(:each) do
        @hash = {}
        @object.add_or_filter("f", @hash, "my_field")        
      end
      it "creates a new filter hash with the field" do
        @hash.should have_key("f")
        @hash["f"].should have_key("my_field")
      end
    end
  end
  
  # def add_and_filter(params, field)
  #   if params.has_key?("f")
  #     params["f"].deep_merge!(add_operator(field))
  #   else
  #     params["f"] = add_operator(field)
  #   end
  # end
  describe "#add_and_filter" do
    context "with existing filter(s)" do
      context "that are deeply nested" do
        before(:each) do
          @params = { "f" => {1 => {"field1" => {"o" => nil}, "field2" => {"o" => nil}}, 2 => {1 => {"field3" => {"o" => nil}}}, "field4" => {"o" => nil}}}
        end
        it "adds a new field with 1 deep if the key doesn't exist" do
          @object.add_and_filter("f", @params, { 1 => "field3"})
          @params["f"][1].should have(3).keys
          @params["f"][1].should have_key("field3")
        end
        it "adds a new field with 2 deep if the key doesn't exist" do
          @object.add_and_filter( "f", @params, {2 => {1 => "field2"}})
          @params["f"][2][1].should have(2).keys
          @params["f"][2][1].should have_key("field2")
        end
        it "doesn't add a new field if the key already exists" do
          @object.add_and_filter("f", @params, { 1 => "field2"})
          @params["f"][1].should have(2).keys
        end
      end
      context "that are not nested" do
        before(:each) do
          @params = { "f" => {"field1" => {"o" => nil}, "field2" => {"o" => nil}}}
        end
        it "adds a new field if the key doesn't exist" do
          @object.add_and_filter("f", @params, "field3")
          @params["f"].should have(3).keys
          @params["f"].should have_key("field3")
        end
      end
    end
    context "without existing filter(s)" do
      before(:each) do
        @hash = {}
        @object.add_and_filter("f", @hash, "my_field")        
      end
      it "creates a new filter hash with the field" do
        @hash.should have_key("f")
        @hash["f"].should have_key("my_field")
      end
    end    
  end
  
  describe "#remove_and_filter" do
    context "with a filter present" do
      it "deletes the part of hash specified by a string" do
        params = {"f" => {"field" => {"o" => nil}}}
        params["f"].should_receive(:delete).with("field")
        @object.remove_and_filter("f", params, "field")
      end
      it "deletes the part of hash specified by a hash" do
        params = {"f" => { 1 => {"field" => {"o" => nil}}}}
        params["f"].should_receive(:deep_delete).with({1 => {"field" => nil}})
        @object.remove_and_filter("f", params, {1 => {"field" => nil}})
      end
    end
    context "without a filter present" do
      it "does nothing" do
        params = {"f" => {"field" => {"o" => nil}}}
        params.stub(:has_key?).with("f").and_return(false)
        params["f"].should_not_receive(:deep_delete)
        @object.remove_and_filter("f", params, "field")
      end
    end
  end
  

  describe "#add_operator" do
    it "returns a hash with an operator indexed by the specified string" do
      @object.add_operator("index").should eql({"index" => {"o" => nil}})
    end
    it "returns a hash with an operator indexed by the specified hash" do
      @object.add_operator({0 => "index"}).should eql({0 => {"index" => {"o" => nil}}})
    end
  end
  
  describe "#apply_filter_actions" do
    context "add OR" do
      context "with no params" do
        it "raise new field", :current => true do
          params = {"or"=>{"raise_field"=>"name", "raise"=>"OR"}}
          flag = @object.apply_filter_actions("triggers", {"name" => "dsafdasg"}, params)
          flag.should be_true
        end
      end
      context "with 'field' present" do
        before(:each) do          
          @params = {"or" => {"field" => "myfield", "commit" => "OR"}}
        end
        it "adds an or filter" do
          @object.should_receive(:add_or_filter).with("name", {"name" => {}}, "myfield", false)
          @object.apply_filter_actions("name", {"name" => {}}, @params)
        end
      end
      context "without 'field' present" do
        before(:each) do
          @params = {"or" => {"field" => nil, "commit" => "OR"}}
        end
        it "does not add an or filter" do
          @object.should_not_receive(:add_or_filter)
          @object.apply_filter_actions("name", {"name" => {}}, @params)
        end
      end
    end
    context "add AND" do
      context "with 'field' present" do
        context "with 'field' present" do
          before(:each) do
            @params = {"and" => {"field" => "myfield", "commit" => "AND"}}
          end
          it "adds an or filter" do
            @object.should_receive(:add_and_filter).with("name", {"name" => {}}, "myfield")
            @object.apply_filter_actions("name", {"name" => {}}, @params)
          end
        end
        context "without 'field' present" do
          before(:each) do
            @params = {"and" => {"field" => nil, "commit" => "OR"}}
          end
          it "does not add an or filter" do
            @object.should_not_receive(:add_and_filter)
            @object.apply_filter_actions("name", {"name" => {}}, @params)
          end
        end
      end
    end
    context "remove" do
      before(:each) do
        @params = {"remove" => "myfield"}
      end
      it "adds an or filter" do
        @object.should_receive(:remove_and_filter).with("name", {"name" => {}}, "myfield")
        @object.apply_filter_actions("name", {"name" => {}}, @params)
      end
    end
  end

end
