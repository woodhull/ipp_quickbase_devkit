class ProjectsController < ApplicationController
   def home
   end
   def all_projects
      @projects, @reportColumns = Projects.all_projects
   end
   def my_open_projects
      @projects = Projects.my_open_projects
   end
   def open_projects
      @projects = Projects.open_projects
   end
   def project_sorted_by_company
      @projects = Projects.project_sorted_by_company
   end
   def projects_sorted_by_priority
      @projects = Projects.projects_sorted_by_priority
   end
   def updated_projects
      @projects, @reportColumns  = Projects.updated_projects
   end
end
