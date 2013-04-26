class Event
  include ::Tire::Model::Persistence
  percolate!

  property :name
  property :description
  property :price, :type => 'double' 
  property :on_sale, :type => 'boolean'
  property :sold_on, :type => 'date'
  property :count, :type => 'integer'


  on_percolate do
    puts "Event matches queries: #{matches.inspect}" unless matches.empty?
  end
end