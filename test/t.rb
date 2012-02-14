comm = Communicator.instance
rank = comm.rank
size = comm.size
data = [rank,`hostname`.chomp]
comm.send((rank+1)%size,0,data)
p [:send, data, :recv, comm.recv((rank-1)%size,0)]
