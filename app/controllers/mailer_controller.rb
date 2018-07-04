class MailerController < ApplicationController
  def subscribe
    require 'rest-client'
    first_name, last_name = get_names(subscribe_params['name'])
    email = subscribe_params['email']
    url, payload, headers = assemble_request(email, first_name, last_name)
    begin
      response = RestClient.post(url, payload, headers)
      render status: response.code
    rescue
      render status: 400
    end
  end

  private

  def subscribe_params
    params.require(:subscriber).permit(:name, :email)
  end

  def assemble_request(email, first_name, last_name)
    url = 'https://us18.api.mailchimp.com/3.0/lists/f77ae56f0c/members/'
    payload = assemble_payload(email, first_name, last_name)
    headers = {
      content_type: :json,
      accept: :json,
      authorization: "apikey #{ENV['api']}"
    }
    [url, payload, headers]
  end

  def assemble_payload(email, first_name, last_name)
    {
      'email_address' => email,
      'status' => 'subscribed',
      'merge_fields' => {
        'FNAME' => first_name,
        'LNAME' => last_name
      }
    }.to_json
  end

  def get_names(names)
    all_names = names.split(' ')
    first_name = all_names.first
    last_name = all_names.drop(1).join(' ')
    [first_name, last_name]
  end
end
