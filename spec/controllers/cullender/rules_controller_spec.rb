require 'spec_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe Cullender::RulesController do
  before(:each) do
    @request.env["cullender.mapping"] = Cullender.mappings[:event]
    Cullender::Rule.reset_callbacks(:create)
  end
  # This should return the minimal set of attributes required to create a valid
  # Rule. As you add validations to Rule, be sure to
  # update the return value of this method accordingly.
  def valid_attributes
    {name: "MyRule"}
  end
  
  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # RulesController. Be sure to keep this updated too.
  def valid_session
    {}
  end

  describe "GET index" do
    before(:each) do
      @rule = Cullender::Rule.create(valid_attributes)
      get :index, {:use_route => :cullender}, valid_session
    end
        
    it "assigns all rules as @rules" do
      assigns(:rules).should eq([@rule])
    end
    
  end


  describe "GET new" do
    it "assigns a new rule as @rule" do
      get :new, {:use_route => :cullender}, valid_session
      assigns(:rule).should be_a_new(Cullender::Rule)
    end
  end

  describe "GET show" do
    it "assigns the requested rule as @rule" do
      rule = Cullender::Rule.create(valid_attributes)
      get :show, {:id => rule.to_param, :use_route => :cullender}, valid_session
      assigns(:rule).should eq(rule)
    end
  end

  describe "POST create" do
    context "with valid params" do
      it "creates a new Rule" do
        expect {
          post :create, {:rule => valid_attributes, :use_route => :cullender}, valid_session
        }.to change(Cullender::Rule, :count).by(1)
      end

      it "assigns a newly created rule as @rule" do
        post :create, {:rule => valid_attributes, :use_route => :cullender}, valid_session
        assigns(:rule).should be_a(Cullender::Rule)
        assigns(:rule).should be_persisted
      end

      it "redirects to the rules_url" do
        post :create, {:rule => valid_attributes, :use_route => :cullender}, valid_session
        response.should redirect_to({"controller"=>controller.params[:controller], "action"=>"index", :use_route => :cullender})
      end
    end

    context "with invalid params" do
      it "assigns a newly created but unsaved rule as @rule" do
        # Trigger the behavior that occurs when invalid params are submitted
        Cullender::Rule.any_instance.stub(:save).and_return(false)
        post :create, {:rule => {:name => "asd"}, :use_route => :cullender}, valid_session
        assigns(:rule).should be_a_new(Cullender::Rule)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Cullender::Rule.any_instance.stub(:save).and_return(false)
        post :create, {:rule => {:name => "asd"}, :use_route => :cullender}, valid_session
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    before(:each) do
      controller.stub(:clean_ids).and_return(nil)
      Cullender::Rule.reset_callbacks(:update)
    end
    context "with valid params" do
      it "updates the requested rule" do
        rule = Cullender::Rule.create(valid_attributes)
        # Assuming there are no other rules in the database, this
        # specifies that the Rule created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        
        Cullender::Rule.any_instance.should_receive(:update_attributes).with({'name' => 'New Name'})
        put :update, {:id => rule.to_param, :rule => {'name' => 'New Name'}, :use_route => :cullender}, valid_session
      end

      it "assigns the requested rule as @rule" do
        rule = Cullender::Rule.create(valid_attributes)
        put :update, {:id => rule.to_param, :rule => valid_attributes, :use_route => :cullender}, valid_session
        assigns(:rule).should eq(rule)
      end

      it "redirects to the rules page" do
        rule = Cullender::Rule.create(valid_attributes)
        put :update, {:id => rule.to_param, :rule => valid_attributes, :use_route => :cullender}, valid_session
        response.should redirect_to({"controller"=>controller.params[:controller], "action"=>"index", :use_route => :cullender})
      end
    end

    context "with invalid params" do
      it "assigns the rule as @rule" do
        rule = Cullender::Rule.create(valid_attributes)
        # Trigger the behavior that occurs when invalid params are submitted
        Cullender::Rule.any_instance.stub(:save).and_return(false)
        put :update, {:id => rule.to_param, :rule => {:name => "asd"}, :use_route => :cullender}, valid_session
        assigns(:rule).should eq(rule)
      end

      it "re-renders the 'show' template" do
        rule = Cullender::Rule.create(valid_attributes)
        # Trigger the behavior that occurs when invalid params are submitted
        Cullender::Rule.any_instance.stub(:save).and_return(false)
        put :update, {:id => rule.to_param, :rule => {:name => "asd"}, :use_route => :cullender}, valid_session
        response.should render_template("show")
      end
    end
  end
  
  describe "DELETE destroy" do
    before(:each)do
      @factory = Cullender::Rule.create(valid_attributes)
      Cullender::Rule.reset_callbacks(:destroy)
    end
    it "destroys the requested model" do
      expect {
        delete :destroy, {:id => @factory.to_param, :use_route => :cullender}, valid_session
      }.to change(@factory.class, :count).by(-1)
    end

    it "redirects to the index url" do
      delete :destroy, {:id => @factory.to_param, :use_route => :cullender}, valid_session
      if defined?(@redirect)
        response.should redirect_to(@redirect)
      else
        response.should redirect_to({"controller"=>controller.params[:controller], "action"=>"index", :use_route => :cullender})
      end
    end

    it "returns a flash message that says that the model has been destroyed" do
      delete :destroy, {:id => @factory.to_param, :use_route => :cullender}, valid_session
      controller.flash[:notice].should eql("Rule was successfully destroyed.")
    end
  end

end