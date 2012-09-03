require 'net/http'
require 'uri'

module SmsGlobal
  class Sender
    include Net

    def initialize(options = {})
      @options = options
      raise 'missing :user' unless @options[:user]
      raise 'missing :password' unless @options[:password]
      @options.each {|k,v| @options[k] = v.to_s if v.present? }
      @base = @options[:base] || 'http://www.smsglobal.com/'
    end

    def send_text(text, to, sender = nil, send_at = nil)
      from = sender || @options[:from] || raise_error('sender is required')
      params = {
        :action => 'sendsms',
        :user => @options[:user],
        :password => @options[:password],
        :from => from,
        :to => to,
        :text => text
      }
      if send_at
        params[:scheduledatetime] = send_at.strftime('%Y-%m-%d %h:%M:%S')
      end
      params[:maxsplit] = @options[:maxsplit] if @options[:maxsplit]
      params[:userfield] = @options[:userfield] if @options[:userfield]
      params[:api] = @options[:api] if @options[:api]

      resp = get(params)

      case resp
      when Net::HTTPSuccess
        if resp.body =~ /^OK: (\d+); ([^\n]+)\s+SMSGlobalMsgID:\s*(\d+)\s*$/
          return {
            :status  => :ok,
            :code    => $1.to_i,
            :message => $2,
            :id      => $3.to_i
          }
        elsif resp.body =~ /^ERROR: (.+)$/
          return {
            :status  => :error,
            :message => $1
          }
        else
          raise "Unable to parse response: '#{resp.body}'"
        end
      else
        return {
          :status  => :failed,
          :code    => resp.code,
          :message => 'Unable to reach SMSGlobal'
        }
      end
    end

    private
    
    def get(params = nil)
      url = URI.join(@base, 'http-api.php')
      if params
        url.query = params.map { |k,v| "%s=%s" % [URI.encode(k.to_s), URI.encode(v)] }.join("&")
      end
      res = HTTP.start(url.host, url.port) do |http|
        http.get(url.request_uri)
      end
    end
  end

end

