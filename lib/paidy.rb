require 'cgi'
require 'net/http'
require 'uri'

require 'paidy/errors/paidy_error'
require 'paidy/errors/authentication_error'
require 'paidy/errors/api_error'

require 'paidy/charge'

require 'paidy/version'

module Paidy
  @api_base = 'https://api.paidy.com'
  @api_version = '2018-04-10'
  @use_ssl = true

  class << self
    attr_accessor :secret_key
  end

  def self.api_uri(path: '')
    URI.parse([@api_base, path].join('/'))
  end

  def self.request(method, path, params = {}, headers = {})
    if secret_key.nil?
      raise Paidy::AuthenticationError.new('API key does not set.' \
        'You should set `Paidy.secret_key = YOUR_PAIDY_SECRET_KEY`.'
      )
    end

    uri = api_uri(path: path)

    case method.to_s.downcase.to_sym
    when :get
      uri += (uri.query.present? ? '&' : '?') + query_parameter(params) if params.present?
      req = Net::HTTP::Get.new(uri)
    when :post
      req = Net::HTTP::Post.new(uri)
      req.body = params.to_json
    end

    req['Content-Type'] = 'application/json'
    req['Paidy-Version'] = @api_version
    req['Authorization'] = "Bearer #{secret_key}"

    req_options = {
      use_ssl: @use_ssl,
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(req)
    end

    body = JSON.parse(response.body)
    case response.code.to_i
    when 200
      body
    else
      raise Paidy::ApiError.new "code: #{body['code']}, title: #{body['title']}, description: #{body['description']}"
    end
  end

  private

  def self.query_parameter(params)
    params.map do |k, v|
      if v.is_a?(Array)
        v.map{ |vv| "#{k}[]=#{CGI.escape(vv)}" }.join('&')
      else
        "#{k}=#{CGI.escape(v)}"
      end
    end.join('&')
  end
end
