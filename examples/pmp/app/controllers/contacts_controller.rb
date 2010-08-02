class ContactsController < ApplicationController
   def project_contacts
      @joinRecords = Contacts.project_contacts
   end
   def companies
      @unionRecords = Contacts.companies
   end
end
