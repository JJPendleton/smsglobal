require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe 'SmsGlobal' do
  include SmsGlobal

  describe 'Sender' do
    before do
      @sender = Sender.new :user => 'DUMMY', :password => 'DUMMY'
    end

    it "requires :user and :password" do
      lambda { Sender.new }.should raise_error
    end

    it "sends SMS correctly" do
      stub_sms_ok
      resp = @sender.send_text('Lorem Ipsum', '12341324', '1234')
      resp[:status].should == :ok
      resp[:code].should == 0
      resp[:message].should == 'Sent queued message ID: 941596d028699601'
    end

    it "gracefully fails" do
      stub_sms_failed
      resp = @sender.send_text('Lorem Ipsum', '12341324', '1234')
      resp[:status].should == :error
      resp[:message].should == 'Missing parameter: from'
    end

    it "hits the right URL" do
      stub_request(:get, 'http://www.smsglobal.com/http-api.php?action=sendsms&from=5678&password=DUMMY&text=xyz&to=1234&user=DUMMY').to_return(:body => 'ERROR: Missing parameter: from')
      @sender.send_text('xyz', '1234', '5678')
    end

    it "gracefully fails on connection error" do
      stub_request(:get, /www.smsglobal.com.*/).to_return(:status => [500, "Internal Server Error"])
      resp = @sender.send_text('xyz', '1234', '5678')
      resp[:status].should == :failed
      resp[:message].should == "Unable to reach SMSGlobal"
    end
  end
end
