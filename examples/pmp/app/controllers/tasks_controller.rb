class TasksController < ApplicationController
   def all_tasks
   end
   def search
      @tasks = Tasks.search(params[:s])
   end
   def search2
      @tasks = Tasks.search2(params[:status])
   end
   def search3
      @tasks = Tasks.search3(params[:status])
   end
end
