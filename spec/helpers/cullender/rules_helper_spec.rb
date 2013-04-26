require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the EventsHelper. For example:
#
# describe EventsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe Cullender::RulesHelper do


    describe "#cullender_collection_or_select" do
      before(:each) do
        helper.stub(:nested_property_prefix).with([]).and_return("prefix")
      end
      context "is base" do
        it "renders the attribute select menu and OR submit btn" do
          html = helper.cullender_collection_or_select(["attr1", "attr2"], [], {:base => true})
          html.should have_selector("select#or_raise_fieldprefix", :text => "attr1\nattr2")
          html.should have_selector("input[type='submit'][name='or[raise]prefix']")
        end
      end
      context "is not a base" do
        it "renders the attribute select menu and OR submit btn" do
          html = helper.cullender_collection_or_select(["attr1", "attr2"])
          html.should have_selector("select#or_fieldprefix", :text => "attr1\nattr2")
          html.should have_selector("input[type='submit'][name='or[commit]prefix']")
        end
      end
    end
  
  describe "#cullender_collection_and_select" do
      before(:each) do
        helper.stub(:nested_property_prefix).with([]).and_return("prefix")
        helper.stub(:option_for_select).and_return("options_for_select")
      end
      it "renders the attribute select menu and AND submit btn" do
        html = helper.cullender_collection_and_select(["attr1", "attr2"])
        html.should have_selector("select#and_fieldprefix", :text => "attr1\nattr2")
        html.should have_selector("input[type='submit'][name='and[commit]prefix']")
      end
  end

  
  describe "#link_to_filter" do
    before(:each) do
      controller.params.merge!(:controller => "cullender/rules", :action => "index", :use_route => :cullender)
      @options = {}
    end
    it "doesn't modify the params hash" do
      params = controller.params
      helper.link_to_filter(:attribute, "Name")
      controller.params == params
    end
    context "with attribute in the filter" do
      before(:each) do
        controller.params.merge!(:filter => {:attribute => {"v" => "value"}})
      end
      it "returns the text of the attribute" do
        html = helper.link_to_filter(:attribute, "Name")
        html.should include "Name"
      end

    end
    context "without the attribute in the filter" do
      it "returns a link to filter by the attribute" do
        html = helper.link_to_filter(:attribute, "Name")
        html.should have_selector("a", :text => "Name")
      end
    end
  end
  
  describe "#remove_filter_link" do
    before(:each) do
      controller.params.merge!(:controller => "cullender/rules", :action => "index", :use_route => :cullender)
      @options = {}
    end
    it "doesn't modify the params hash" do
      params = controller.params
      helper.remove_filter_link(:attribute, "value", 2)
      controller.params == params
    end
    context "with attribute in the filter" do
      before(:each) do
        controller.params.deep_merge!({:filter => {"attribute" => {"o" => 1, "v" => "value"}}})
      end
      it "returns a link to remove the filter" do
        html = helper.remove_filter_link(:attribute, "value", 2)
        html.should have_selector("a", :text => "remove")
      end
    end
    context "without attribute in the filter" do
      it "returns the count" do
        html = helper.remove_filter_link(:attribute, "value", 2)
        html.should have_selector("span", :text => "2")
      end
    end
  end

  # def render_property_tree(name,  hash, options = {}, hierarchy = [], &block)
  #   options.merge!(:class => "group level_#{hierarchy.length}")
  #   last_key =  hash.keys.last
  #   html = content_tag :div, options do
  #   hash.each do |field, value|
  #     if value.keys.include?("o")
  #       block.call property_item(name, field, value, hierarchy), last_key == field ? 1 : -1, hierarchy
  #     else
  #       hierarchy.push(field)
  #       block.call render_property_tree(name, value, {}, hierarchy, &block), last_key == field ? 0 : -1, hierarchy
  #     end
  #   end
  #   end if hash.present?
  #   hierarchy.pop()
  #   html
  # end
  describe "#render_property_tree" do
    context "with an empty hash" do
      it "returns nil" do
        helper.render_property_tree("f", {}, {}).should be_nil
      end
    end
    context "hash value has name and value key" do
      it "should render the next level of the hash" do
        inner_hash = {:these => {"o" => 1, "v" => "values"}}
        helper.should_receive(:property_item).with("f", :these, {:type =>"string"}, {"o" => 1, "v" => "values"}, []).once
        helper.render_property_tree("f", {:these => {:type => "string"}}, inner_hash, {}, []) do |a, b, c|
          "#{a}, #{b}, #{c}"
        end
      end      
    end
    context "hash value does not have name and value key" do
      it "should render the next level of the hash" do
        inner_hash = {"these" => {"o" => 1, "v" => "values"}}
        html = helper.render_property_tree("f", {:these => {:type => "text_field"}}, {"key" => inner_hash}, {}, []) do |a, b, c|
          "#{a}, #{b}, #{c}"
        end
        html.should have_selector("div[class='group level_0']")
      end
    end
  end
  
  describe "#property_item" do
    before(:each) do
      helper.stub(:nested_property_prefix).and_return("prefix")
      helper.stub(:property_value_field).and_return("")
      helper.should_receive(:property_value_field).once
      # Cullender::Event.stub(:field_operators).with('field_name').and_return({"name1" => "value1", "name2" => "value2", "name3" => "value3"})
      # Cullender::Event.stub(:properties).and_return(['field_name', 'field1', 'field2', 'field3'])
      # Cullender::Event.stub(:property_types).and_return({'field_name' => 'string', 'field2' => 'string', 'field3' => 'string'})
      
    end
    it "wraps the content with a tag with the field name as a class" do
      html = helper.property_item("name", :field_name, {:type => "string"}, {}, [1,2,3])
      html.should have_selector("div[class='item field_name']")
    end

    it "is html safe" do
      html = helper.property_item("name", :field_name, {:type => "string"}, {}, [1,2,3])
      html.should be_html_safe
    end

    it "returns a label with the field name" do
      html = helper.property_item("name", :field_name, {:type => "string"}, {}, [1,2,3])
      html.should have_selector("label[for='prefix[field_name][v]']", :text => "field_name")
    end
    # it "returns a hidden field with the field name" do
    #   html = helper.property_item("name", "field_name", {}, [1,2,3])
    #   puts html
    #   html.should have_selector("input[name='prefix[n]'][type='hidden']")
    # end
    
    context "without an operator set in the value_hash" do
      it "returns a select menu to select an operator" do
        html = helper.property_item("name", :field_name, {:type => "string"}, {}, [1,2,3])
        html.should have_selector("select[name='prefix[field_name][o]']")
        (1..3).each {|i| html.should have_selector("option[value='term']", :text => I18n.t("cullender.operators.term"))}
      end
    end
    
    context "with an operator set in the value_hash" do
      it "returns a select menu with the operator selected" do
        html = helper.property_item("name", :field_name, {:type => "string"}, {"o" => "term"}, [1,2,3])
        html.should have_selector("option[value='term'][selected='selected']")
      end
    end
  end

  describe "#property_value_field" do
    context "with invalid value" do
      before(:each) do
        helper.stub(:call_options).with("field_name").and_return({:class => "my_property"})
      end
      context "when field type is a number" do
        it "returns a number field with the value set" do
          # Cullender::Event.stub(:field_type).with("field_name").and_return("number")
          html = helper.property_value_field("field_name", "number_field", nil, {}, "prefix")
          html.should have_selector("input[type='number'][name='prefix[field_name][v]']")
        end
      end
      context "when field type is a range" do
        it "returns a range field with the value set" do
          # Cullender::Event.stub(:field_type).with("field_name").and_return("range")
          html = helper.property_value_field("field_name", "range_field", nil, {}, "prefix")
          html.should have_selector("input[type='range'][name='prefix[field_name][v]']")
        end
      end
      context "when field type is a select menu" do
        it "returns a select menu with the value set" do
          helper.stub(:options_for_select).with({}, nil).and_return("options_for_select")
          # Cullender::Event.stub(:field_type).with("field_name").and_return("select")
          html = helper.property_value_field("field_name", "select", nil, {}, "prefix")
          html.should have_selector("select[name='prefix[field_name][v]']", :text => "options_for_select")
        end
      end
      context "when field type is text" do
        # it "returns a text field with the value set" do
        #   Event.stub(:field_type).with("field_name").and_return(Event::TEXT)
        #   html = helper.property_value_field("field_name", nil, "prefix")
        #   html.should have_selector("input", :type => "text", :name => "prefix[v]", :class => "my_property")
        # end
      end
      context "when field type is not found" do
        it "returns a text field with the value set" do
          # Cullender::Event.stub(:field_type).with("field_name").and_return(3454)
          html = helper.property_value_field("field_name", "text_field", nil, {}, "prefix")
          html.should have_selector("input[type='text'][name='prefix[field_name][v]']")
        end
      end
      context "when field type is datetime" do
        it "returns datetime select menus with the value set" do
          time = Time.zone.now
          helper.stub(:set_datetime).and_return(time)
          # Cullender::Event.stub(:field_type).with("field_name").and_return("datetime")
          html = helper.property_value_field("field_name", "datetime", nil, {}, "prefix")
          html.should have_selector("select[name='prefix[field_name][v][year]']")
          html.should have_selector("select[name='prefix[field_name][v][month]']")
          html.should have_selector("select[name='prefix[field_name][v][day]']")
          html.should have_selector("select[name='prefix[field_name][v][hour]']")
          html.should have_selector("select[name='prefix[field_name][v][minute]']")
        end
      end
      context "when field type is date" do
        it "returns date select menus with the value set" do
          date = Date.today
          helper.stub(:set_date).and_return(date)
          # Cullender::Event.stub(:field_type).with("field_name").and_return("date")
          html = helper.property_value_field("field_name", "date", nil, {}, "prefix")
          html.should have_selector("select[name='prefix[field_name][v][year]']")
          html.should have_selector("select[name='prefix[field_name][v][month]']")
          html.should have_selector("select[name='prefix[field_name][v][day]']")
        end
      end
    end
  
    context "with a valid value" do
      before(:each) do
        helper.stub(:call_options).with("field_name").and_return({})
      end
      context "when field type is a number" do
        it "returns a number field with the value set" do
          # Cullender::Event.stub(:field_type).with("field_name").and_return("number")
          html = helper.property_value_field("field_name", "number_field", 3, {}, "prefix")
          html.should have_selector("input[type='number'][name ='prefix[field_name][v]'][value='3']")
        end
      end
      context "when field type is a range" do
        it "returns a range field with the value set" do
          # Cullender::Event.stub(:field_type).with("field_name").and_return("range")
          html = helper.property_value_field("field_name", "range_field", 3, {}, "prefix")
          html.should have_selector("input[type='range'][name ='prefix[field_name][v]'][value='3']")
        end
      end
      context "when field type is text" do
        # it "returns a text field with the value set" do
        #   Event.stub(:field_type).with("field_name").and_return(Event::TEXT)
        #   html = helper.property_value_field("field_name", "my_value", "prefix")
        #   html.should have_selector("input", :type => "text", :name => "prefix[v]", :value => "my_value")
        # end
      end
    end
  end

  
  # def nested_property_prefix(hierarchy)
  #   "f#{hierarchy.inject("") {|result, item| result += "[#{item}]"}}"
  # end
  describe "#nested_property_prefix" do
    it "returns a string with the proper hash code" do
      helper.nested_property_prefix([1,2,3,4,5]).should == "[1][2][3][4][5]"
    end
    it "returns a string with the proper hash code and a prefix" do
      helper.nested_property_prefix([1,2,3,4,5], "pre").should == "pre[1][2][3][4][5]"
    end
  end
  
  describe ".formatted_triggers" do
    it "displays the 'AND'ed triggers" do
      input = {"amount"=>{"o"=>"lt", "v"=>"fsfdb"}, "card_number"=>{"o"=>"gt", "v"=>"fdbsb"}, "start_at"=>{"o"=>"gt", "v"=>"dfbsb"}}
      output = "(amount < fsfdb AND card_number > fdbsb AND start_at > dfbsb)"
      helper.formatted_triggers(input).should eql(output)
    end

    it "displays nested 'OR'ed triggers" do
      input = {"0"=>{"0"=>{"amount"=>{"o"=>"lt", "v"=>"fsfdb"}, "card_number"=>{"o"=>"gt", "v"=>"fdbsb"}, "start_at"=>{"o"=>"gt", "v"=>"dfbsb"}}, "1"=>{"card_bank_number"=>{"o"=>"gt", "v"=>"fbdsb"}}}, "1"=>{"card_bank_number"=>{"o"=>"gt", "v"=>"fsdbfd"}}}
      output = "(((amount < fsfdb AND card_number > fdbsb AND start_at > dfbsb) OR (card_bank_number > fbdsb)) OR (card_bank_number > fsdbfd))"
      helper.formatted_triggers(input).should eql(output)
    end

  end
  
  describe ".filter_to_s" do
    it "writes the filter as a string" do
      helper.filter_to_s("amount", {"o"=>"lt", "v"=>"fsfdb"}).should eql("amount < fsfdb")
    end
  end
  
  # describe "#format_for_datatype" do
  #   it "calls number_to_currency when type is a currency" do
  #     helper.should_receive(:number_to_currency).with(123.23)
  #     helper.format_for_datatype(123.23, Event::CURRENCY)
  #   end
  #   it "calls short localize when type is a date" do
  #     I18n.should_receive(:localize).with(Time.zone.at(1333078177), :format => :short)
  #     helper.format_for_datatype(1333078177, Event::DATE)
  #   end
  #   it "calls short localize when type is a datetime" do
  #     I18n.should_receive(:localize).with(Time.zone.at(1333078177), :format => :long)
  #     helper.format_for_datatype(1333078177, Event::DATETIME)
  #   end
    
  #   it "calls number_with_delimiter when type is an integer" do
  #     helper.should_receive(:number_with_delimiter).with(12323)
  #     helper.format_for_datatype(12323, Event::INTEGER)
  #   end
    
  #   it "calls number_with_precision when type is an decimal" do
  #     helper.should_receive(:number_with_precision).with(12323.23242)
  #     helper.format_for_datatype(12323.23242, Event::DECIMAL)
  #   end
    
  #   it "calls number_to_percentage when type is a percentage" do
  #     helper.should_receive(:number_to_percentage).with(12)
  #     helper.format_for_datatype(12, Event::PERCENTAGE)
  #   end
    
  #   it "calls number_to_human_size when type is a filesize" do
  #     helper.should_receive(:number_to_human_size).with(1333078177)
  #     helper.format_for_datatype(1333078177, Event::FILESIZE)
  #   end
    
  #   it "returns the value if case is not present" do
  #     helper.format_for_datatype(1333078177, 9999).should == 1333078177
  #   end
  # end
    
end
