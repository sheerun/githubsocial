begin
  Rails.cache.clear
  puts "Cache cleared..."
rescue
  puts "Cache clearing failed..."
end
