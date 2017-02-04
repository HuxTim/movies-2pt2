class MGenres
	
	def initialize
		@movies = createHashTable
	end

	def createHashTable
		f = open("./ml-100k/u.item")
	   	f_item = f.readlines
	    f.close
	    item = []
	    while f_item.length > 0
	     	ex = f_item.shift
	      	ex = ex[0,ex.length-1].force_encoding("iso-8859-1").split("|")
			ex.delete_at(0)
			ex.delete_at(0)
			ex.delete_at(0)
			ex.delete_at(0)
			ex.delete_at(0)
	      	(0..18).each do |i|
				if ex[i] == ""
		  			ex[i] = "0"
				end
				ex[i] = ex[i].to_i
	      	end
	    	item.push(ex)
	    end 
		return item
	end

	def getGenres(m_id)
		return @movies[m_id-1]
	end


end
