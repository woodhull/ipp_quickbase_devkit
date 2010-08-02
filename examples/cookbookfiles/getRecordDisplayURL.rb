
require 'QuickBaseMisc'

r = QuickBase::Misc.decimalToBase32(24105)
puts "<a href=\"https://www.quickbase.com/db/8emtadvk?a=dr&r=#{r}\">Ruby API home page</a>"

=begin

The above code prints this HTML link -

<a href="https://www.quickbase.com/db/8emtadvk?a=dr&r=ztj">Ruby API home page</a>

=end
