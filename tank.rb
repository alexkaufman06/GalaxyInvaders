class Tank
	attr_reader :x, :y, :radius, :speed, :type, :hp

	def initialize(window, level, player)
		@radius = 20
		@x = rand(window.width - 2 * @radius) + @radius
		@y = 0
		@hp = 5
		@image = Gosu::Image.new('images/tank.png')
		@speed = 0.25 + (level / 6)
		@player = player
		@type = "Tank"
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

	def hit_by_bullet
		@hp -= 1
	end

	def hit_by_missile
		@hp -= 3
	end
end