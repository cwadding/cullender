module Cullender
  class RulesController < CullenderController
    before_action :set_rule, only: [:show, :edit, :update, :destroy]
    include Controllers::FilterLogic
    
    # TODO should route without resource. ie not event/rules just /rules
    # GET /rules
    def index
      @rules = Cullender::Rule.all
    end

    # GET /rules/1
    def show
      params.deep_merge!({"rule" => {"triggers" => @rule.triggers}})
    end

    # GET /rules/new
    def new
      @rule = Cullender::Rule.new(name: params[:name])
    end

    # POST /rules
    def create
      flag = apply_filter_actions("triggers", params[:rule], params)
      @rule = Cullender::Rule.new(rule_params)
      respond_to do |format|
        if flag
            format.html {redirect_to send("new_#{resource_name}_rule_url".to_sym,params[:rule])}
            format.js { render "create"}
        else
          if @rule.save
            format.html {redirect_to send("#{resource_name}_rules_url".to_sym), notice: 'Rule was successfully created.'}
            format.js {redirect_to send("#{resource_name}_rules_url".to_sym), notice: 'Rule was successfully created.'}
          else
            format.html {render action: 'new'}
            format.js {render action: 'new'}
          end
        end
      end
    end

    # PATCH/PUT /rules/1
    def update
      if !apply_filter_actions("triggers", params[:rule], params) && @rule.update_attributes(rule_params)
        redirect_to send("#{resource_name}_rules_url".to_sym), notice: 'Rule was successfully updated.'
      else
        render action: 'show'
      end
    end

    # DELETE /rules/1
    def destroy
      @rule.destroy
      redirect_to send("#{resource_name}_rules_url".to_sym), notice: 'Rule was successfully destroyed.'
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_rule
        @rule = Cullender::Rule.find(params[:id])
      end

      # Never trust parameters from the scary internet, only allow the white list through.
      def rule_params
        params.require(:rule).permit!#(:name, :triggers => {})
      end
  end
end
