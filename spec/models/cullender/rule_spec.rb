require 'spec_helper'

describe Cullender::Rule do

  # describe "#fire" do
  #   before(:each) do
  #     @rule = Rule.new
  #   end
  #   context "with events" do
  #     before(:each) do
  #       @event = Factory(:event)
  #       Event.stub(:filter_between).with(nil, nil, @rule.triggers).and_return([@event])
  #     end
  #     context "with labels" do
  #       before(:each) do
  #         @rule.labels = ["label1", "label2"]
  #       end
  #       it "adds labels to the events" do
  #         @rule.fire(nil, nil)
  #         @event.should have(2).tags
  #         @event.tags.should include "label1"
  #         @event.tags.should include "label2"
  #       end
  #     end
  #   end
  #   context "with no events" do
  #     before(:each) do
  #       Event.stub(:filter_between).with(nil, nil, @rule.triggers).and_return([])
  #     end
  #     it "returns nil" do
  #       @rule.fire(nil, nil).should be_nil
  #     end
  #   end
  # end

  def single_attr(key = "attr", value = 100)
    {key => {"o" => "term", "v" => value}}
  end


  describe ".to_query_proc" do
    before(:each) do
      @rule = Cullender::Rule.new
    end
    it "returns a Proc object" do
      # @rule.should_receive(:to_query).and_return(::Tire::Search::Query.new)
      query_proc = @rule.to_query_proc
      query_proc.should be_a_kind_of(Proc)
    end
  end


  describe "#number_of_fields" do
    before(:each) do
      @rule = Cullender::Rule.new
    end
    context "with triggers not set" do
      it "returns 0" do
        @rule.send(:number_of_fields).should == 0
      end
    end
    context "single level" do
      context "single field" do
        before(:each) do
          @rule.triggers = single_attr
        end
        it "returns the count" do
          @rule.send(:number_of_fields).should == 1
        end
      end

      context "multiple fields" do
        before(:each) do
          @rule.triggers = single_attr("attr1", 100).merge!(single_attr("attr2", 200))
        end
        it "returns the count" do
          @rule.send(:number_of_fields).should == 2
        end
      end
    end
    context "deep nesting" do
      context "single level" do
        before(:each) do
          @rule.triggers = {
            "1" => single_attr("attr1", 100).merge!(single_attr("attr2", 200)),
            "2" => single_attr("attr3", 300).merge!(single_attr("attr4", 400))           
          }
        end
        it "returns the count" do
          @rule.send(:number_of_fields).should == 4
        end
      end
      context "different levels" do
        before(:each) do
          @rule.triggers = {
          "1" => {
            "1" => single_attr("attr1", 100).merge!(single_attr("attr2", 200)),
            "2" => single_attr("attr3", 300).merge!(single_attr("attr4", 400))           
          },
          "2" => single_attr("attr5", 500).merge!(single_attr("attr6", 600)),
          "3" => single_attr("attr7", 700).merge!(single_attr("attr8", 800))
        }
        end
        it "returns the count" do
          @rule.send(:number_of_fields).should == 8
        end
      end      
    end    
  end



  describe "#to_query", :current => true do
    before(:each) do
      @rule = Cullender::Rule.new
    end
    context "a single attr" do
      before(:each) do
        @rule.triggers = single_attr
      end
      it "parses the filter for matching" do
        result = @rule.to_query.to_hash
        result.should == {
          :term => {
              "attr" => {:term => 100}
          }
        }
      end
    end

    context "multiple filter 'AND'ed together" do
      before(:each) do
        @rule.triggers = single_attr("attr1", 100).merge!(single_attr("attr2", 200))
      end
      it "parses the filter for matching" do
        result = @rule.to_query.to_hash
        result.should == {:bool=>{:must=>[{:term=>{"attr1"=>{:term=>100}}}, {:term=>{"attr2"=>{:term=>200}}}]}}
        # {
        #   :filtered => {
        #     :filter => {
        #       :and => [
        #         {:term => {:attr1 => "100"}},
        #         {:term => {:attr2 => "200"}}
        #       ]
        #     }  
        #   }
        # }
      end
    end

    context "multiple 'AND'ed filters 'OR'ed together" do
      before(:each) do
        @rule.triggers = {
            "1" => single_attr("attr1", 100).merge!(single_attr("attr2", 200)),
            "2" => single_attr("attr3", 300).merge!(single_attr("attr4", 400))           
          }
      end
      it "parses the filter for matching" do
        result = @rule.to_query.to_hash
        result.should == {
          :bool=>{
            :should=>[
              {
                :bool=>{
                  :must=>[
                    {:term=>{"attr1"=>{:term=>100}}},
                    {:term=>{"attr2"=>{:term=>200}}}
                  ]
                }
              },{
                :bool=>{
                  :must=>[
                    {:term=>{"attr3"=>{:term=>300}}},
                    {:term=>{"attr4"=>{:term=>400}}}
                  ]
                }
              }
            ]
          }
        }

        # {
        #   :filtered => {
        #     :filter => {
        #       :and => [
        #         :or => [
        #           {:and => [
        #             {:term => {:attr1 => "100"}},
        #             {:term => {:attr2 => "200"}}
        #           ]},  
        #           {:and => [
        #             {:term => {:attr3 => "300"}},
        #             {:term => {:attr4 => "400"}}
        #           ]}
        #         ]
        #       ]
        #     }  
        #   }
        # }
      end
    end
    
    context "deeply nested multiple 'AND'ed filters 'OR'ed together" do
      before(:each) do
        @rule.triggers = {
          "1" => {
            "1" => single_attr("attr1", 100).merge!(single_attr("attr2", 200)),
            "2" => single_attr("attr3", 300).merge!(single_attr("attr4", 400))           
          },
          "2" => {
            "1" => single_attr("attr5", 500).merge!(single_attr("attr6", 600)),
            "2" => single_attr("attr7", 700).merge!(single_attr("attr8", 800)),          
          }
        }
      end
      it "parses the filter for matching" do
        result = @rule.to_query.to_hash
        result.should == {
          :bool=>{
            :should=>[
              {
                :bool=>{
                  :should=>[
                    {
                      :bool=>{
                        :must=>[
                          {:term=>{"attr1"=>{:term=>100}}},
                          {:term=>{"attr2"=>{:term=>200}}}
                        ]
                      }
                    },{
                      :bool=>{
                        :must=>[
                          {:term=>{"attr3"=>{:term=>300}}},
                          {:term=>{"attr4"=>{:term=>400}}}
                        ]
                      }
                    }
                  ]
                }
              },{
                :bool=>{
                  :should=>[
                    {
                      :bool=>{
                        :must=>[
                          {:term=>{"attr5"=>{:term=>500}}},
                          {:term=>{"attr6"=>{:term=>600}}}
                        ]
                      }
                    },{
                      :bool=>{
                        :must=>[
                          {:term=>{"attr7"=>{:term=>700}}},
                          {:term=>{"attr8"=>{:term=>800}}}
                        ]
                      }
                    }
                  ]
                }
              }
            ]
          }
        }
        # {
        #   :filtered => {
        #     :filter => {
        #       :and => [
        #         :or => [
        #           {:or => [
        #             {:and => [
        #               {:term => {:attr1 => "100"}},
        #               {:term => {:attr2 => "200"}}
        #             ]},  
        #             {:and => [
        #               {:term => {:attr3 => "300"}},
        #               {:term => {:attr4 => "400"}}
        #             ]}
        #           ]},
        #           {:or => [
        #             {:and => [
        #               {:term => {:attr5 => "500"}},
        #               {:term => {:attr6 => "600"}}
        #             ]},  
        #             {:and => [
        #               {:term => {:attr7 => "700"}},
        #               {:term => {:attr8 => "800"}}
        #             ]}
        #           ]}
        #         ]
        #       ]
        #     }  
        #   }
        # }
      end
    end
    
  end


  # describe "#to_search" do
  #   before(:each) do
  #     @rule = Cullender::Rule.new
  #   end
  #   context "a single filter" do
  #     before(:each) do
  #       @rule.triggers = single_attr
  #     end
  #     it "parses the filter for matching" do
  #       result = @rule.to_search.to_hash
  #       result.should == {
  #         :filter => {
  #           :term => {:attr => "100"}
  #         }  
  #       }
  #     end
  #   end

  #   context "multiple filter 'AND'ed together" do
  #     before(:each) do
  #       @rule.triggers = single_attr("attr1", 100).merge!(single_attr("attr2", 200))
  #     end
  #     it "parses the filter for matching" do
  #       result = @rule.to_search.to_hash
  #       result.should == {
  #         :filter => {
  #           :and => [
  #             {:term => {:attr1 => "100"}},
  #             {:term => {:attr2 => "200"}}
  #           ]
  #         }  
  #       }
  #     end
  #   end

  #   context "multiple 'AND'ed filters 'OR'ed together" do
  #     before(:each) do
  #       @rule.triggers = {
  #           "1" => single_attr("attr1", 100).merge!(single_attr("attr2", 200)),
  #           "2" => single_attr("attr3", 300).merge!(single_attr("attr4", 400))           
  #         }
  #     end
  #     it "parses the filter for matching" do
  #       result = @rule.to_search.to_hash
  #       result.should == {
  #         :filter => {
  #           :or => [
  #             {:and => [
  #               {:term => {:attr1 => "100"}},
  #               {:term => {:attr2 => "200"}}
  #             ]},  
  #             {:and => [
  #               {:term => {:attr3 => "300"}},
  #               {:term => {:attr4 => "400"}}
  #             ]}
  #           ]
  #         }  
  #       }
  #     end
  #   end
    
  #   context "deeply nested multiple 'AND'ed filters 'OR'ed together" do
  #     before(:each) do
  #       @rule.triggers = {
  #         "1" => {
  #           "2" => single_attr("attr1", 100).merge!(single_attr("attr2", 200)),
  #           "1" => single_attr("attr3", 300).merge!(single_attr("attr4", 400))           
  #         },
  #         "2" => {
  #           "1" => single_attr("attr5", 500).merge!(single_attr("attr6", 600)),
  #           "2" => single_attr("attr7", 700).merge!(single_attr("attr8", 800)),          
  #         }
  #       }
  #     end
  #     it "parses the filter for matching" do
  #       result = @rule.to_search.to_hash
  #       result.should == {
  #         :filter => {
  #           :or => [
  #             {:or => [
  #               {:and => [
  #                 {:term => {:attr1 => "100"}},
  #                 {:term => {:attr2 => "200"}}
  #               ]},  
  #               {:and => [
  #                 {:term => {:attr3 => "300"}},
  #                 {:term => {:attr4 => "400"}}
  #               ]}
  #             ]},
  #             {:or => [
  #               {:and => [
  #                 {:term => {:attr5 => "500"}},
  #                 {:term => {:attr6 => "600"}}
  #               ]},  
  #               {:and => [
  #                 {:term => {:attr7 => "700"}},
  #                 {:term => {:attr8 => "800"}}
  #               ]}
  #             ]}
  #           ]
  #         }  
  #       }
  #     end
  #   end
    
  # end




  
end
# == Schema Information
#
# Table name: rules
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)
#  description :string(255)
#  type        :string(255)
#  enabled     :boolean(1)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

