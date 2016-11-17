class Player
	def initialize(window)
		@x = 200
		@y = 500
		@angle = 0
		@image = Gosu::Image.new('images/ship.png')
		@velocity_x = 0
		@velocity_y = 0
	end

	def draw
		@image.draw_rot(@x, @y, 1, @angle)
	end

	def turn_right
		@angle += 3
	end

	def turn_left
		@angle -= 3
	end

	def accelerate
		@velocity_x += Gosu.offset_x(@angle, 1)
		@velocity_y += Gosu.offset_y(@angle, 1)
	end

	def move
		@x += @velocity_x
		@y += @velocity_y
		@velocity_x *= 0.9
		@velocity_y *= 0.9
	end
end