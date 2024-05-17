# frozen_string_literal: true

class Enrolment
  include Mongoid::Document
  include Mongoid::Timestamps

  attr_accessor :user_prompt

  field :thread_id, type: String
  validates_presence_of :thread_id

  before_create :create_thread

  def create_thread
    response = client.threads.create
    self.thread_id = response['id']
  end

  def create_message
    client.messages.create(thread_id:,
                           parameters: {
                             role: 'user', # Required for manually created messages
                             content: user_prompt
                           })

    create_run
  end

  def create_run
    client.runs.create(thread_id:,
                       parameters: {
                         assistant_id:,
                         max_prompt_tokens: 256,
                         max_completion_tokens: 1024,
                         stream: proc do |chunk, _bytesize|
                                   if chunk['object'] == 'thread.message.delta'
                                     print chunk.dig('delta', 'content', 0, 'text',
                                                     'value')
                                   end
                                 end
                       })
  end

  def first_id
    messages['first_id']
  end

  def answer
    return unless first_id

    client.messages.retrieve(thread_id:, id: first_id)['content'].first['text']['value']
  end

  def messages
    @messages ||= client.messages.list(thread_id:)
  end

  def client
    @client ||= OpenAI::Client.new(log_errors: true)
  end

  def assistant_id
    'asst_2EoqXtpQIXGnOaLF8aDkgXD9'
  end

  def run
    response = client.runs.create(thread_id:,
                                  parameters: {
                                    assistant_id:,
                                    max_prompt_tokens: 256,
                                    max_completion_tokens: 16
                                  })
    response['id']
  end
end
