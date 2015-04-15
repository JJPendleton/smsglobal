$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'smsglobal'
require 'rspec'
require 'webmock/rspec'

include SmsGlobal

RSpec.configure do |config|
  config.include WebMock::API
end

def stub_sms(response_body)
  stub_request(:get, /http:\/\/www.smsglobal.com\/http-api.php.*/).to_return(:body => response_body)
end

def stub_sms_ok
  stub_sms("OK: 0; Sent queued message ID: 941596d028699601\nSMSGlobalMsgID:6764842339385521")
end

def stub_sms_failed
  stub_sms("ERROR: Missing parameter: from")
end
