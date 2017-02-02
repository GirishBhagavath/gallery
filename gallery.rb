class Base
  attr_accessor :id
end


class Visitor < Base
  attr_accessor :in_time, :out_time
  def initialize(visitor_id)
    @id = visitor_id
  end

  def checkout(timestamp)
    @out_time - @in_time 
  end
end



class Room < Base
  attr_accessor :visitors, :visitor_count, :total_time_spent

  def initialize(room_id)
    @id = room_id
    @visitors = []
    @visitor_count = 0
    @total_time_spent = 0
  end

  def checkin_visitor(visitor_id, timestamp)
    visitor = @visitors.find{|visitor| visitor.id == visitor_id}
    unless visitor
      visitor = Visitor.new(visitor_id)
      @visitors << visitor
      @visitor_count += 1
    end
    visitor.in_time = timestamp.to_i
  end

  def checkout_visitor(visitor_id, timestamp)
    visitor = @visitors.find{|visitor| visitor.id == visitor_id}
    unless visitor
      visitor = Visitor.new(visitor_id)
      @visitors << visitor
      @visitor_count += 1
      visitor.in_time = timestamp.to_i
    end
    visitor.out_time = timestamp.to_i
    @total_time_spent += visitor.checkout(timestamp.to_i)
  end
end

class Gallery
  class << self
    attr_accessor :rooms
    def find_or_create_room(room_id) #Find or create room
      @rooms ||= []
      room = @rooms.find{|room| room.id == room_id}
      unless room
        room = Room.new(room_id)
        @rooms << room
      end
      room
    end
  end

  def self.job(inp)
    visitor_id, room_id, token, timestamp = inp.squeeze(' ').strip.split(" ")
    room = find_or_create_room(room_id) if room_id
    case token
    when "I"
      room.checkin_visitor(visitor_id, timestamp) #Make visitor check in
    when "O"
      room.checkout_visitor(visitor_id, timestamp) #Make visitor check out
    else
      puts "wrong input"
    end
  end
end

puts "Enter entries"
puts "----------Once you finished type exit--------"
inp_cmd =''
until inp_cmd == "exit"
  inp_cmd = gets.chop
  Gallery.job(inp_cmd) unless inp_cmd == "exit"
end

Gallery.rooms.sort_by{ |r| r.id.to_i}.each do |room|
  avg = (room.total_time_spent.to_f / room.visitor_count.to_f).round
  puts "Room #{room.id}, #{avg} minute average visit, #{room.visitor_count} visitor total"
end
