class TimeCardsController < ApplicationController
   def summary
      @time_cards = TimeCards.summary
   end
end
