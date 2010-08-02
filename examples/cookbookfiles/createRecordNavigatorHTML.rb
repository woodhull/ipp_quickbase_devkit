
require 'QuickBaseClient'
require 'QuickBaseMisc'

qbc = QuickBase::Client.new

i = 0
recordViewLinks = ""
qbc.iterateRecords("8emtadvk",["Message ID#","Subject"]){|msg|
  if i < 15
    r = QuickBase::Misc.decimalToBase32(msg['Message ID#'])
    recordViewLinks << "<a href=\"https://www.quickbase.com/db/8emtadvk?a=dr&r=#{r}\" target=\"RecordContainer\">#{msg['Subject']}</a><br>"
  end
  i += 1
}

html = <<EndHTML

<html>
<head>
<style type="text/css">
td { white-space: nowrap; vertical-align: top }
</style>
</head>
<body>
<table border="1" >
<tr><td><b>Community Forum Records</b><td><td></tr>
<tr>
<td>
#{recordViewLinks}
</td>
<td>
<iframe name="RecordContainer" Width="800" Height="650" />
</td>
</tr>
</table>
</body>
</html>

EndHTML

File.open("QuickBaseCommunityForumRecordViewer.html","w"){|f|f.write(html)}
