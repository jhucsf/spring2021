#! /usr/bin/env ruby

MAX_LEVEL = ENV.has_key?('MAX_LEVEL') ? ENV['MAX_LEVEL'].to_i : 6

OPS = ENV.has_key?('OPS') ? ENV['OPS'].chars : ['+', '+', '-', '*', '*', '/']

def leaf(r)
  return (r.rand(20) + 1).to_s
end

def randexpr(r, level)
  if level < MAX_LEVEL
    n = r.rand(8)
    if n < 6
      raise "Wrong number of operators!" if OPS.length != 6
      op = OPS[n]
      return "#{randexpr(r, level + 1)} #{randexpr(r, level + 1)} #{op}"
    else
      return leaf(r)
    end
  else
    return leaf(r)
  end
end

def genrand(r)
  done = false
  ex = nil
  #n = 0
  while !done
    ex = randexpr(r, 0)
    #n += 1
    done = !(/^\d+$/.match(ex))
  end
  #puts "#{n} times"
  return ex
end

def evalexpr(expr)
  stack = []
  expr.split(/\s+/).each do |tok|
    case tok
      when '+'
        right = stack.pop.to_i
        left = stack.pop.to_i
        val = left + right
        #puts "#{left} + #{right} = #{val}"
        stack.push(val)
      when '-'
        #val = stack.pop.to_i + stack.pop.to_i
        right = stack.pop.to_i
        left = stack.pop.to_i
        val = left - right
        #puts "#{left} - #{right} = #{val}"
        stack.push(val)
      when '*'
        right = stack.pop.to_i
        left = stack.pop.to_i
        val = left * right
        #puts "#{left} * #{right} = #{val}"
        stack.push(val)
      when '/'
        #val = stack.pop.to_i + stack.pop.to_i
        right = stack.pop.to_i
        left = stack.pop.to_i
        # throw exception if division by 0 attempted
        raise "Division by zero!" if right == 0
        val = left / right
        quot = left.to_f / right.to_f
        if val < 0 && val != quot
          # special case: round up if result is negative
          val += 1
        end
        #puts "#{left} / #{right} = #{val}"
        stack.push(val)
      else
        stack.push(tok.to_i)
    end
  end
  raise "Wrong stack depth" if stack.size != 1
  return stack[0]
end

r = Random.new
done = false
while !done
  expr = genrand(r)
  begin
    result = evalexpr(expr)
    puts "expect #{result} '#{expr}'"
    done = true
  rescue Object => s
    # division by 0 occurred, try again
    #STDERR.puts "Exception: #{s}"
  end
end
