require "thread"
require "socket"
require "singleton"

class Communicator
  include Singleton
  attr_reader :rank, :size, :queue

  def initialize
    @master_info = ENV['PDRB_INFO'].split
    @rank = @master_info[2].to_i
    @server = TCPServer.open(0)

    s = TCPSocket.open(*@master_info[0..1])
    Marshal.dump([@rank,@server.addr[1],Process.pid], s)
    s.close

    s = @server.accept
    @rank, @host_list = Marshal.load(s)
    s.close
    @size = @host_list.size

    @queue = Array.new(@size){Hash.new{|h,k| h[k]=Queue.new}}
    Thread.start do
      comm_loop
    end
  end

  def comm_loop
    loop do
      s = @server.accept
      rank,tag,obj = Marshal.load(s)
      s.close
      q = @queue[rank][tag]
      q.enq(obj)
    end
  end

  def send(rank,tag,obj)
    s = TCPSocket.open(*@host_list[rank][0..1])
    Marshal.dump([@rank,tag,obj], s)
    s.close
  end

  def recv(rank,tag)
    q = @queue[rank][tag]
    q.deq
  end
end

Communicator.instance
