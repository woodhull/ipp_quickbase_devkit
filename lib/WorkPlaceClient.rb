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

require 'QuickBaseClient'

module QuickBase
  # Client that defaults the host to workplace.intuit.com 
  class WorkPlaceClient < Client
   def initialize(username=nil,password=nil,appname=nil,useSSL=true,printRequestsAndResponses=false, 
                       stopOnError=false,showTrace=false,apptoken=nil,debugHTTPConnection=false,proxy_options = nil)
      super(username,password,appname,useSSL,printRequestsAndResponses,stopOnError,showTrace,"workplace",apptoken,debugHTTPConnection,"intuit",proxy_options)
   end
   def WorkPlaceClient.init(options)
     options ||= {}
     options["useSSL"] ||= true
     options["printRequestsAndResponses"] ||= false
     options["stopOnError"] ||= false
     options["showTrace"] ||= false
     options["debugHTTPConnection"] ||= false
     options["proxy_options"] ||= nil
     instance = WorkPlaceClient.new( options["username"], 
                                     options["password"], 
                                     options["appname"],
                                     options["useSSL"], 
                                     options["printRequestsAndResponses"],
                                     options["stopOnError"],
                                     options["showTrace"],
                                     options["apptoken"],
                                     options["debugHTTPConnection"],
                                     options["proxy_options"])
   end
 end
end

 