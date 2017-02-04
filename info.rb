class Info
	
	def initialize
	#u.info {#@users | #@movies | #ratings}
    	f = open("./ml-100k/u.info")
    	@users = f.readline.split(" ")[0].to_i
    	@movies = f.readline.split(" ")[0].to_i
    	f.close
	end
	
	attr_reader :users, :movies
end
