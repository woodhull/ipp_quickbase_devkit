require 'QuickBaseTwitterConnector'

QuickBase::TwitterConnector.new

=begin

This is a example of what you will see.
The Twitter Connector will run in a loop, checking for new information every few minutes.
Probably the most useful feature of this Connector is the ability to send two types of
automated response, static text and the results from simple REST queries. 
Remember that Twitter only accepts the first 140 characters of text.

The Connector automatically creates a QuickBase application using your QuickBase
username and your Twitter username.

----------------------------------------------------------------------------------

Please enter the Quickbase username to use for this session: fred_flintstone@internet.com
Please enter the Quickbase password to use for this session: wilma
Please enter the Twitter username to use for this session: fred_flintstone
Please enter the Twitter password to use for this session: wilma


Please enter a number to select the connection type:

1 - Send Twitter messages to QuickBase.
2 - Send QuickBase messages to Twitter.
3 - Exchange messages between QuickBase and Twitter.
4 - Send automated replies from QuickBase to Twitter.
5 - All the above.

5


Getting 'friends' Twitter Status since Fri, 28 Mar 2008 13:47:24 -0700.
Getting Direct Messages from Twitter since Fri, 28 Mar 2008 13:47:24 -0700.
Sending messages from QuickBase to Twitter added since Fri, 28 Mar 2008 13:47:24 -0700.
Getting Direct Messages from Twitter since Fri, 28 Mar 2008 13:47:24 -0700.
Automated Direct Message sent to wilma_flintstone: what's for dinner?: rex ribs

=end
