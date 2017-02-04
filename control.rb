require './info'
require './validator'
require './ratings'

class Control
	#this class manages execution of prediction algorithm on a test set 
	#of movie rating data. 
	def initialize
		puts "Starting program"
		i = Info.new
		bs = Ratings.new("./ml-100k/#{takeBaseSet}", i)
		ts = Ratings.new("./ml-100k/#{takeTestSet}", i)
		runValidator(bs,ts)
	end
	
	#switch base set file name using this, must be in ./ml-100k
	def takeBaseSet
		return "ua.base"
	end
	
	#switch test set file name using this
	def takeTestSet
		return "ua.test"
	end
	
	def runValidator(bs, ts)
		v = Validator.new(bs,ts)
		puts "Running validator"
		v.results
	end
end

Control.new