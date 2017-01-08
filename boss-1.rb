class Boss_1
	attr_reader :x, :y, :radius, :hp

	def initialize(window, player)
		@radius = 75
		@x = window.width / 2
		@y = 0
		@image = Gosu::Image.new('images/boss_1.png')
		@speed = 1.5
		@player = player
		@hp = 50
	end

	def move
		if @y < 90
			@y += 0.5
		elsif
			@direction = Gosu.angle(@x, @y, @player.x, @player.y)
			@x += Gosu.offset_x(@direction, @speed)
		end
	end

	def hit_by_bullet
		@hp -= 1
	end

	def hit_by_missile
		@hp -= 3
	end

	def draw
		@image.draw(@x - @radius, @y - @radius, 1)
	end
end