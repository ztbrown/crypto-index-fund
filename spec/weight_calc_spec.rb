require_relative '../lib/weight_calculation.rb'
require 'rspec/mocks'

describe "weight calculations" do 
  it "calculates the weights" do 
    total = 0.0
    currencies = [20,20,20,20,20,100]
    currencies.each do |currency|
      total += weight_calc(currency, currencies)
    end
    expect(total).to eq(1.0)
  end 
end
