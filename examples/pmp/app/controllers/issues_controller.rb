class IssuesController < ApplicationController
   def filter_issues
      @issues = Issues.filter_issues(params[:s])
   end
end
