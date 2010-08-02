
require 'QuickBaseClient'

qbc = QuickBase::Client.new

reportsHTML = ""
reportNames = qbc.getReportNames("8emtadvk")
reportNames.each{|reportName|
  report = qbc.lookupQueryByName(reportName) 
  reportID = report.attributes["id"]
  reportsHTML << "<a href=\"https://www.quickbase.com/db/8emtadvk?a=q&qid=#{reportID}\" target=\"ReportContainer\" >#{reportName}</a><BR>"
}

html =   "<html>"
html << "<head>"
html << "<style type=\"text/css\">"
html << "td { white-space: nowrap; vertical-align: top }"
html << "</style>"
html << "</head>"
html << "<body>"
html << "<table border=\"1\" >"
html << "<tr><td><b>Community Forum Reports</b><td><td></tr>"
html << "<tr>"
html << "<td><b>"
html << reportsHTML
html << "</b></td>"
html << "<td>"
html << "<iframe name=\"ReportContainer\" Width=\"700\" Height=\"800\" />"
html << "</td>"
html << "</tr>"
html << "</table>"
html << "</body>"
html << "</html>"

File.open("QuickBaseCommunityForumReports.html","w"){|f|f.write(html)}
