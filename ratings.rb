require './mGenres.rb'
require './info.rb'

class Ratings
	
	def initialize(fn, i)
		puts "initializing #{fn}"
		@file = open(fn)
		@info = i
		@reviews = extractdata(@file)
		#reviews[u_id][m_id]=>rating
		#reviews[u_id].keys=>list of movies watched
		@userdata = retrieveuserdata(@reviews)
		#userdata[u_id] = {genre ratings and views}
	end
	
	def extractdata(f)
    	f_data = f.readlines
		reviews = { }
	    while f_data.length > 0
		    entry = f_data.shift
		    entry = entry[0, entry.length-1].split(/\t/)
			if !(reviews.key?(entry[0].to_i))
				reviews[entry[0].to_i] = { }
			end
			reviews[entry[0].to_i][entry[1].to_i] = entry[2].to_i
		end	
		return reviews
	end
	
	def  retrieveuserdata(r)
		userdata = { }
		genre = MGenres.new()
		(1..@info.users).each do |i|
			userdata[i] = {"rating" => 0, "views" => 0, 1 => [0, 0], 2 => [0, 0], 3 => [0, 0], 4 => [0, 0],
			5 => [0, 0], 6 => [0, 0], 7 => [0, 0], 8 => [0, 0], 9 => [0, 0], 10 => [0, 0], 11 => [0, 0],
			12 => [0, 0], 13 => [0, 0], 14 => [0, 0], 15 => [0, 0], 16 => [0, 0], 17 => [0, 0], 18 => [0, 0],
			19 => [0, 0]}
			#each subarray holds [avg rating, views] for each genre
			@reviews[i].each do |key|
				#increase total views and rating
				if userdata[i]["views"] == 0
					userdata[i]["views"] += 1 
					userdata[i]["rating"] = @reviews[i][key[0]]
				else
					userdata[i]["views"] += 1 
					userdata[i]["rating"] = (userdata[i]["rating"]*(userdata[i]["views"]-1)+@reviews[i][key[0]])/userdata[i]["views"]
				end
				#updates total views and rating for genre
				(0..genre.getGenres(key[0]).count).each do |j|
					if genre.getGenres(key[0])[j] == 1
						if userdata[i][j+1][1] == 0
							userdata[i][j+1] = [@reviews[i][key[0]], 1]
						else
							userdata[i][j+1] = [(userdata[i][j+1][0]*userdata[i][j+1][1]+@reviews[i][key[0]])/(userdata[i][j+1][1]+1), (userdata[i][j+1][1]+1)]
						end
					end
				end	
			end
		end
		return userdata
	end

	def similarity(user1, user2)
	    #find user's 6 top favorite genres
	    #if they share any sees difference in position
	    #low dispersion means highly similar preferences
	    #for each match, find the dispersion in list. score .16666 for every match, .4*1/(1+dispersion)
	    u1favoritegenres = []
	    u2favoritegenres = []
    	(1..19).each do |i|
      	#create user1 list
      		if @userdata[user1][i][1] != 0
        		if u1favoritegenres.empty?
          			u1favoritegenres.push(i)
        		else
          			temp = []
					while !u1favoritegenres.last.nil? && @userdata[user1][i][1] > @userdata[user1][u1favoritegenres.last][1]
						temp.push(u1favoritegenres.pop)
					end
						u1favoritegenres.push(i)
					while !temp.empty?
						u1favoritegenres.push(temp.pop)
					end
					while u1favoritegenres.length > 6
						u1favoritegenres.pop()
					end
				end
			end
		end
		
		#create user2 list
		(1..19).each do |i|
			#create user1 list
			if @userdata[user2][i][1] != 0
				if u2favoritegenres.empty?
					u2favoritegenres.push(i)
				else
					temp = []
					while !u2favoritegenres.last.nil? && @userdata[user2][i][1] > @userdata[user2][u2favoritegenres.last][1]
						temp.push(u2favoritegenres.pop)
					end
					
					u2favoritegenres.push(i)
					while !temp.empty?
						u2favoritegenres.push(temp.pop)
					end
					while u2favoritegenres.length > 6
					u2favoritegenres.pop()
					end
				end
			end
		end

		dispersion = []
		(0...u1favoritegenres.length-1).each do |i|
			(0...u2favoritegenres.length-1).each do |j|
				if u1favoritegenres[i] == u2favoritegenres[j]
					dispersion.push((i-j).abs)
				end
			end
		end

		score = 0
		while !dispersion.empty?
			score += 12.666 + 4*((5-dispersion.pop)/5)
		end

		return score
	end

	def most_similar(user, size)
		sim_users = []
		(1...@userdata.count).each do |i|
			if i != user
				sim_users.push({"u_id"=>i, "similarity"=>similarity(user, i)})
			end
		end
		#print sim_users
		sim_users = sim_users.sort_by { |hsh| hsh["similarity"] }.reverse
		sim_users = sim_users[0..(size-1)]
		(0...sim_users.count).each do |i|
			sim_users[i] = sim_users[i]["u_id"]
		end
		return sim_users
	end
  
	def predict(user, movie) 
		sim_users = most_similar(user, 100)
		temp_x = 0
		temp_y = 0
		x = 0
		y = 0
		xy = 0
		x2 = 0
		y2 = 0
		n = 0
		#go through each movie the user has watched
		@reviews[user].each do |key|
			#place their reviews as x variable, average similar user's review as y
			n += 1
			temp_x = getaverage(sim_users, key[0])
			temp_y = @reviews[user][key[0]]
			x += temp_x
			y += temp_y
			xy += temp_x * temp_y
			x2 += temp_x * temp_x
			y2 += temp_y *temp_y
		end

		if n == 0 
			return 4
		end
		a = ((y*x2)-(x*xy))/((n*x2)-(x*x))
		b = ((n*xy)-(x*y))/((n*x2)-(x*x))
		prediction = (a/3 + (getaverage(sim_users, movie)))
		if prediction < 0
			return 0
		elsif prediction > 5
			return 5
		else
			return prediction
		end
		
	end
  
	def getaverage(users, movie)
		count = 0
		avgrating = 0
		users.each do |user|
			if @reviews[user].key?(movie)
				avgrating += @reviews[user][movie]
				count += 1
			end
		end
		if avgrating != 0
			return (avgrating/count)
		end
		return 0
	end
	
	def getSize
		return @reviews.count
	end
	
	def getRating(user, movie)
		if @reviews[user].key?(movie) == true
			return @reviews[user][movie]
		end
		return 0
	end
	
	def getReviews
		return @reviews
	end

end