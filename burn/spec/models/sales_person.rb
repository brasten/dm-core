require File.dirname(__FILE__) + '/person'

class SalesPerson < Person
  property :commission, Fixnum
end