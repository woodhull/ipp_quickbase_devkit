#--#####################################################################
# Copyright (c) 2009 Gareth Lewis and Intuit, Inc.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.opensource.org/licenses/eclipse-1.0.php
#
# Contributors:
#    Gareth Lewis - Initial contribution.
#    Intuit Partner Platform.
#++#####################################################################

require 'QuickBaseCommandlineClient'

module QuickBase

# class WebClient: a web server that responds to requests to run command files
# present on the local machine. This extends QuickBase via URLs on web pages.
#
# e.g. if there is an 'uploadSpreadsheet.qbc' command file next to this QuickBaseClient.rb
# file on your machine, it can be run from a web page by starting 'WebClient.new' on your
# machine and placing 'http://127.0.0.1:2358/qbc/uploadSpreadsheet.qbc' in a link on the
# web page.
#
# Any request that does not include "/qbc/" will shut down the server.
class WebClient < CommandLineClient

   attr_reader :runNow, :running, :ipAddress, :port, :thread

   def initialize( runNow = true, ipAddress = 'localhost', port = 2358 )
      super()
      @runNow = runNow
      @doStop = @running = false
      if @runNow
         start( ipAddress, port )
      else
         @ipAddress, @port = ipAddress, port
      end
   end

   def stop()
      if @running and @thread
         puts "------ #{Time.now} ------"
         puts "------ Web client stopped ------"
         Thread.kill( @thread )
         @doStop = @running = @thread = nil
      end
   end

   def start( ipAddress = 'localhost', port = 2358 )

      stop if @running
      @ipAddress, @port = ipAddress, port

      @thread = Thread.new {

         begin
            server = TCPServer.new( ipAddress, port )
            @running = true

            puts "------ #{Time.now} ------"
            puts "------ Web client started on #{ipAddress}:#{port} ------"

            while ( session = server.accept )

               request = session.gets

               puts "------ #{Time.now} ------"
               puts "Request: #{request}"

               if request.include?( " /qbc/" )
                  commandFile = ""
                  requestParts = request.split( " " )
                  requestParts.each{ |requestPart|
                     if requestPart.include?( "/qbc/" )
                        commandFile = requestPart.split( "/" ).last
                     end
                  }
                  if commandFile.length > 1 and FileTest.readable?( commandFile )
                     puts "------ Attempting to run '#{commandFile}'."
                     run( commandFile )
                     puts "------ Finished running command file '#{commandFile}'."
                     session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                     session.print "<html><head><META HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\"></META></head><body><h1>"
                     session.print "Finished running command file '#{commandFile}'.<br>Please press the browser's Back button"
                     session.print "</h1></body></html>\r\n"
                  else
                     puts "------ '#{commandFile}' is not a valid command file."
                     session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                     session.print "<html><head><META HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\"></META></head><body><h1>'#{commandFile}' is not a valid command file.</h1></body></html>\r\n"
                  end
                  session.close
               elsif not request.include?( "GET /favicon.ico " )
                  session.print "HTTP/1.1 200/OK\r\nContent-type: text/html\r\n\r\n"
                  session.print "<html><head><META HTTP-EQUIV=\"Pragma\" CONTENT=\"no-cache\"></META></head><body><h1>Invalid request.</h1></body></html>\r\n"
                  session.close
                  stop()
               end
           end
        rescue StandardError => e
           puts "Error: #{e}"
        end
    }
    @thread.join
    @running
  end

end  #class WebClient -------------------------------------

end #module QuickBase ---------------------------------------------

# Run a command line client as a local web server that runs command files.
# e.g. ruby QuickBaseWebClient.rb runwebclient
if __FILE__ == $0 and ARGV.length > 0
   if ARGV[0] == "runwebclient"
      ARGV.shift
      if ARGV.length > 1
         qbwc = QuickBase::WebClient.new( true, ARGV[0], ARGV[1] )
      elsif ARGV.length > 0
         qbwc = QuickBase::WebClient.new( true, ARGV[0] )
      else
         qbwc = QuickBase::WebClient.new( true )
      end
   end
end
