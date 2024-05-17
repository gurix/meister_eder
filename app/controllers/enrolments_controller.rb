# frozen_string_literal: true

class EnrolmentsController < ApplicationController
  before_action :load_enrolment, only: %i[edit update]
  def index
    @enrolments = Enrolment.all
  end

  def new
    @enrolment = Enrolment.new(thread_id: new_thread)
    redirect_to edit_enrolment_path(@enrolment) if @enrolment.save!
  end

  def edit; end

  def update
    @enrolment.update(enrolment_params)
    @enrolment.create_message
    redirect_to edit_enrolment_path(@enrolment)
  end

  private

  def load_enrolment
    @enrolment = Enrolment.find(params[:id])
  end

  def client
    @client ||= OpenAI::Client.new(log_errors: true)
  end

  def new_thread
    response = client.threads.create
    response['id']
  end

  def enrolment_params
    params.require(:enrolment).permit(:user_prompt)
  end
end
