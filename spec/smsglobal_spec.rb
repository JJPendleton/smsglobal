require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'SmsGlobal' do
  include SmsGlobal

  describe 'Sender' do
    before do
      @sender = Sender.new :user => 'DUMMY', :password => 'DUMMY'
    end

    it "requires :user and :password" do
      expect { Sender.new }.to raise_error
    end

    it "sends SMS correctly" do
      stub_sms_ok
      resp = @sender.send_text('Lorem Ipsum', '12341324', '1234')
      expect(resp[:status]).to eq :ok
      expect(resp[:code]).to eq 0
      expect(resp[:message]).to eq 'Sent queued message ID: 941596d028699601'
    end

    it "gracefully fails" do
      stub_sms_failed
      resp = @sender.send_text('Lorem Ipsum', '12341324', '1234')
      expect(resp[:status]).to eq :error
      expect(resp[:message]).to eq 'Missing parameter: from'
    end

    it "hits the right URL" do
      stub_request(:get, 'http://www.smsglobal.com/http-api.php?action=sendsms&from=5678&password=DUMMY&text=xyz&to=1234&user=DUMMY').to_return(:body => 'ERROR: Missing parameter: from')
      @sender.send_text('xyz', '1234', '5678')
    end

    it "gracefully fails on connection error" do
      stub_request(:get, /www.smsglobal.com.*/).to_return(:status => [500, "Internal Server Error"])
      resp = @sender.send_text('xyz', '1234', '5678')
      expect(resp[:status]).to eq :failed
      expect(resp[:message]).to eq "Unable to reach SMSGlobal"
    end
  end
end
