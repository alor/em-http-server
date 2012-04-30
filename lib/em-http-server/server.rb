require 'rubygems'
require 'eventmachine'

module EventMachine
  module Http
    class Server < EM::P::HeaderAndContentProtocol

      # everything starts from here.
      # Protocol::HeaderAndContentProtocol does the dirty job for us
      # it will pass headers and content, we just need to parse the headers
      # the fill the right variables
      def receive_request headers, content

        # save the whole headers array, verbatim
        @http_headers = headers

        # parse the headers into an hash to be able to access them like:
        #  @http[:host]
        #  @http[:content_type]
        @http = headers_2_hash headers

        # parse the HTTP request
        parse_first_header headers.first

        # save the binary content
        @http_content = content

        # invoke the method in the user-provided instance
        if respond_to?(:process_http_request)
          process_http_request
        end
      end

      # parse the first HTTP header line
      # get the http METHOD, URI and PROTOCOL
      def parse_first_header(line)

        parsed = line.split(' ')

        send_error(400, "Bad request") unless parsed.size == 3

        @http_request_method, uri, @http_protocol = parsed

        send_error(400, "Bad request") unless uri.start_with? '/'

        @http_request_uri, @http_query_string = uri.split('?')
      end

      def send_error(code, desc)
        string = "HTTP1/1 #{code} #{desc}\r\n"
        string << "Connection: close\r\n"
        string << "Content-type: text/plain\r\n"
        string << "\r\n"
        string << "Detected error: HTTP code #{code}"
        send_data string
        close_connection_after_writing
      end

    end
  end
end


if __FILE__ == $0

  class HTTPHandler < EM::Http::Server

    def process_http_request
      puts  @http_request_method
      puts  @http_request_uri
      puts  @http_query_string
      puts  @http_protocol
      puts  @http[:cookie]
      puts  @http[:content_type]
      puts  @http_content
      puts  @http.inspect
    end

  end

  port = 8080
  # all the events are handled here
  EM::run do
    EM::start_server("0.0.0.0", port, HTTPHandler)
    puts "Listening on port #{port}..."
  end

end