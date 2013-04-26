require 'spec_helper'

describe "Rules" do


  describe "POST /rules" do
    context "percolation" do
      before(:each) do
        ::Tire.index('_percolator').refresh
      end
      # test the creating of a rule and percolate command in elasticsearch
      it "works! (now write some real specs)" do
        Cullender::Rule.create(:name => "example", :triggers => {})
        
      end
    end
  end

end
