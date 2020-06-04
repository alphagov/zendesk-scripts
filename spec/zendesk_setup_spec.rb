require_relative '../lib/zendesk_setup'

RSpec.describe 'zendesk_setup' do
  let(:env) do
    {
      'ZENDESK_URL' => 'https://api.zendesk',
      'ZENDESK_USER_EMAIL' => 'bob@domain.tld',
      'ZENDESK_TOKEN' => 'very-secret',
    }
  end

  it 'should configure a zendesk client' do
    client = nil
    expect { client = create_zendesk_client_from_env(env) }.not_to raise_error
    expect(client).not_to be_nil
  end

  context 'with a zendesk client' do
    let(:client) { create_zendesk_client_from_env(env) }

    it 'should enable retries' do
      expect(client.config.retry).to be true
    end

    it 'should set the username and authentication type' do
      username_token = "#{env['ZENDESK_USER_EMAIL']}/token"
      expect(client.config.username).to eq(username_token)
    end

    it 'should set the token' do
      expect(client.config.token).to eq(env['ZENDESK_TOKEN'])
    end

    it 'should set the URL' do
      expect(client.config.url).to eq(env['ZENDESK_URL'])
    end
  end
end
