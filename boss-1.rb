class Boss_1
	attr_reader :x, :y, :radius

	def initialize(window, player)
		@radius = 75
		@x = window.width / 2
		@y = 0
		@image = Gosu::Image.new('images/boss_1.png')
		@speed = 1
		@player = player
	end

	def move
		if @y < 90
			@y += 0.5
		end
		@direction = Gosu.angle(@x, @y, @player.x, @player.y)
		@x += Gosu.offset_x(@direction, @speed)
	end

	def draw
		@image.draw(@x - @radius, @y - @radius, 1)
	end
end