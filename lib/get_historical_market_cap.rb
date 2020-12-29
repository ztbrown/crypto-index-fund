require 'watir'

def get_historical_market_cap(name, start_date, end_date)
  if File.exists?("./currencies/#{name}-#{start_date}#{end_date}.txt")
    puts "using cached data for #{name}"
    return File.readlines("./currencies/#{name}-#{start_date}#{end_date}.txt").map {|line| line.to_i}
  else
    browser = Watir::Browser.new :chrome, headless: true
    browser.goto "https://coinmarketcap.com/currencies/#{name}/historical-data/?start=#{start_date}&end=#{end_date}" 
    table = browser.tables.find{ |table| table[0][0].text == "Date" }
    begin
      mc = table.trs.collect{ |tr| tr[6].text.split(',').join.to_i }

      mc.shift

      File.open("./currencies/#{name}-#{start_date}#{end_date}.txt", 'w') do |file| 
        mc.each { |el| file.puts(el)  }
      end

      return mc
    rescue
      puts "#{name} failed to find market cap"
      return [0]
    end
  end
end
