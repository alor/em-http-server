#a minimal example for blocking the request and answering it
#only if a certain condition is satisfied
require 'rubygems'
require 'eventmachine'
require 'em-http-server'

$request_arr = [] # stores the requests

class HTTPHandler < EM::HttpServer::Server

   #this function will only add the request to the array
    def process_http_request
      puts "A new request is recieved"
      $request_arr.push(self)
    end

    def http_request_errback e
      puts e.inspect
    end

end

EM::run do
  EM::start_server("0.0.0.0", 8080, HTTPHandler)
 #depending on your condition you might want to go with a check on every tick
 #the period is on 1 second so it is easy for the human eye to trace the flow of the exapmle
  do_work = EventMachine::PeriodicTimer.new(1){
    rand_num = rand(10)
    puts "This tick the random number is: #{rand_num} \n"
    #in this simple examle, we will answer the requests if the
    #random number is less than 5. We will print it on every proc
    puts "The size of the array is: #{$request_arr.size}"
    if rand_num < 5
      for index in 0 ... $request_arr.size
           response = EM::DelegatedHttpResponse.new($request_arr[index])
           response.status = 200
           response.content_type 'text/html'
           response.content = "Hello world!"
           response.send_response
           $request_arr.delete_at(index)
      end
    end
  } 
end
