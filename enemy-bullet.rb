class Enemy_Bullet
	attr_reader :x, :y, :radius

	def initialize(window, x, y, angle, level)
		@x = x
		@y = y
		@direction = angle
		@image = Gosu::Image.new('images/enemy-bullet.png')
		@radius = 3
		@window = window
		@speed = 4 + (level / 5)
	end

	def move
		@x += Gosu.offset_x(@direction, @speed)
		@y += Gosu.offset_y(@direction, @speed)
	end

	def draw
		@image.draw(@x - @radius, @y - @radius, 1)
	end

	def onscreen?
		right = @window.width + @radius
		left = -@radius
		top = -@radius
		bottom = @window.height + @radius
		@x > left and @x < right and @y > top and @y < bottom
	end
end