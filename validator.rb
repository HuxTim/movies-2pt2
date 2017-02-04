require './ratings'

class Validator

	def initialize(bs,ts)
		@bs = bs
		@ts = ts.getReviews
	end

	def results
		count = 0
		correct = 0
		one_away = [0, 0]
		#[prediction less than reality, vice versa]
		two_away = [0, 0]
		three_away = [0, 0]
		four_away = [0, 0]
		results = [0, 0, 0, 0, 0]
		predictions = [0, 0, 0, 0, 0]
		users = @ts.keys
		(0..users.count-1).each do |i|
			movies = @ts[users[i]].keys
			(0..movies.count-1).each do |j|
				if(count % 100 == 0) && count > 0
					puts "100 predictions passed in: #{Time.now-time}"
				end
				time = Time.now
				prediction = @bs.predict(users[i],movies[j])
				reality = @ts[users[i]][movies[j]]
				results[reality-1] += 1
				predictions[prediction-1] += 1
				if prediction == reality
					correct += 1
				end
				if (prediction-reality).abs == 1
					if (prediction-reality) < 0
						one_away[0] += 1
					else
						one_away[1] += 1
					end
				elsif (prediction-reality).abs == 2
					if (prediction-reality) < 0
						two_away[0] += 1
					else
						two_away[1] += 1
					end
				elsif (prediction-reality).abs == 3
					if (prediction-reality) < 0
						three_away[0] += 1
					else
						three_away[1] += 1
					end
				else (prediction-reality).abs == 4
					if (prediction-reality) < 0
						four_away[0] += 1
					else
						four_away[1] += 1
					end
					
				end
			puts "# of correct guesses: #{correct}/count"
			puts "predicted distribution: #{predictions}"
			puts "real distribution: #{results}"
			puts "one away: #{one_away} two away: #{two_away} three away: #{three_away} four away: #{four_away} "
			end
			end
		
	end
	

end