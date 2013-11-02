module Cullender
  class EventsController < ApplicationController
    # before_action :set_event, only: [:show, :edit, :update, :destroy]

    # GET /events
    def index
      @events = Event.all
    end

    # GET /events/1
    def show
      @event = Event.find(params[:id])
    end

    # GET /events/new
    def new
      @event = Event.new
    end

    # GET /events/1/edit
    def edit
      @event = Event.find(params[:id])
    end

    # POST /events
    def create
      @event = Event.new(event_params)

      if @event.save
        redirect_to @event, notice: 'Event was successfully created.'
      else
        render action: 'new'
      end
    end

    # PATCH/PUT /events/1
    def update
      @event = Event.find(params[:id])
      if @event.update(event_params)
        redirect_to @event, notice: 'Event was successfully updated.'
      else
        render action: 'edit'
      end
    end

    # DELETE /events/1
    def destroy
      @event = Event.find(params[:id])
      @event.destroy
      redirect_to events_url, notice: 'Event was successfully destroyed.'
    end

    private

      # Never trust parameters from the scary internet, only allow the white list through.
      def event_params
        params.require(:event).permit(:name)
      end
  end
end
