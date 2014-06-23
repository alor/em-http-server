#a minimal example for parsing parameters of the request
require 'rubygems'
require 'eventmachine'
require 'em-http-server'
require 'cgi'

class HTTPHandler < EM::HttpServer::Server
   def process_http_request
     puts "New request accepted!"
     response_cont = "my_paramf"
    #checks if the request has any params what so ever
     if  self.instance_variable_get("@#{'http_query_string'}").nil?
      response_cont = "No parameters"
     else
       param_str =  self.instance_variable_get("@#{'http_query_string'}")
       param_hash = CGI::parse(param_str)
       #handle the case where there are params, but not the one you want
	   if !param_hash.has_key?("my_param")
         response_cont = "Invalid parameters"
       else 
         response_cont = "It works. Sent value is:  #{param_hash['my_param']}"
       end
     end
                                    
        response = EM::DelegatedHttpResponse.new(self)
        response.status = 200
        response.content_type 'text/html'
        response.content = response_cont
        response.send_response
   end

   def http_request_errback e
      # printing the whole exception
   end

end
EM::run do
  EM::start_server("0.0.0.0", 8080, HTTPHandler)
end
