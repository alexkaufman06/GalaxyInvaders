class Enemy
	attr_reader :x, :y, :radius, :speed

	def initialize(window, level)
		@radius = 20
		@x = rand(window.width - 2 * @radius) + @radius
		@y = 0
		@image = Gosu::Image.new('images/enemy.png')
		@speed = 1 + (level / 6)
	end

	def move
		@y += @speed
	end

	def draw
		@image.draw(@x - @radius, @y - @radius, 1)
	end

	def increase_speed
		@speed += 15
	end
end