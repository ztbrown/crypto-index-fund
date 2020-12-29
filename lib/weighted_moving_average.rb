#!/usr/bin/env ruby
require 'json'

def wma(arr, alpha)
  # make it backwards compatible
  alpha ||= 1.0 / arr.length 
  numerator = 0.0
  denominator = 0.0
  arr.each.with_index do |val, i|
    numerator += val * (Math.exp(i*alpha*-1))
    denominator += (Math.exp(i*alpha*-1))
  end
  (numerator / denominator).round(3)
end

