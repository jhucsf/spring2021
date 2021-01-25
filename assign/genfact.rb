#! /usr/bin/env ruby

require 'open3'

# minimum and maximum number of hex digits for values to create
MINLEN = 10
MAXLEN = 100

def create_rand_bignum(ndigits)
  s = ''
  ndigits.times do
    s += '0123456789abcdef'[rand(16)]
  end
  return s.to_i(16)
end

# create two random bignum values
a = create_rand_bignum(MINLEN + rand(MAXLEN - MINLEN + 1))
b = create_rand_bignum(MINLEN + rand(MAXLEN - MINLEN + 1))

which = rand(3)

case which
  when 0
    # generate an addition fact
    puts "#{a.to_s(16)} + #{b.to_s(16)} = #{(a + b).to_s(16)}"

  when 1
    # generate a subtraction fact
    if a < b
      tmp = a
      a = b
      b = tmp
    end
    puts "#{a.to_s(16)} - #{b.to_s(16)} = #{(a - b).to_s(16)}"

  when 2
    # generate a comparison fact
    if a < b
      puts "#{a.to_s(16)} < #{b.to_s(16)}"
    elsif a > b
      puts "#{a.to_s(16)} > #{b.to_s(16)}"
    else
      # unlikely, but possible
      puts "#{a.to_s(16)} = #{b.to_s(16)}"
    end
end
