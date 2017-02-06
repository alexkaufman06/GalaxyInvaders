class Boss_2
	attr_reader :x, :y, :radius, :hp, :exploded

	def initialize(window, player)
		@radius = 75
		@x = window.width / 2
		@y = 0
		@image = Gosu::Image.new('images/boss_2.png')
		@speed = 2
		@player = player
		@exploded = false
		@hp = 100
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

	def explode
		@exploded = true
	end
end