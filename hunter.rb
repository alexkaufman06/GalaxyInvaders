class Hunter
	attr_reader :x, :y, :radius, :speed

	def initialize(window, level, player)
		@radius = 20
		@x = rand(window.width - 2 * @radius) + @radius
		@y = 0
		@image = Gosu::Image.new('images/hunter.png')
		@speed = 1 + (level / 6)
		@player = player
	end

	def move
		@direction = Gosu.angle(@x, @y, @player.x, @player.y)
		@x += Gosu.offset_x(@direction, @speed)
		@y += Gosu.offset_y(@direction, @speed)
	end

	def draw
		@direction = Gosu.angle(@x, @y, @player.x, @player.y)
		@image.draw_rot(@x, @y, 1, @direction - 180)
	end
end