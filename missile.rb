class Missile
	SPEED = 5
	attr_reader :x, :y, :radius

	def initialize(window, x, y, angle, enemies)
		@x = x
		@y = y
		@direction = angle
		@image = Gosu::Image.new('images/player-bullet.png')
		@radius = 3
		@window = window
		# @nearest_enemy = enemies[0] #Use this variable and not the one below for sticky bomb
		@enemies = enemies
	end

	def move
		@distance = 0
		@distance_nearest = 0
		@nearest_enemy = @enemies[0]
		if @enemies.count > 0
			@enemies.each do |enemy|
				if @enemies[0] == enemy
					@distance = Gosu.distance(enemy.x, enemy.y, @x, @y)
					@distance_nearest = Gosu.distance(@nearest_enemy.x, @nearest_enemy.y, @x, @y)
					if @distance < @distance_nearest
						@nearest_enemy = enemy
					end

					@direction = Gosu.angle(@x, @y, @nearest_enemy.x, @nearest_enemy.y)
					@x += Gosu.offset_x(@direction, SPEED)
					@y += Gosu.offset_y(@direction, SPEED)
				end
			end
		else
			# Could have the missiles move around the player?
			# @direction = Gosu.angle(@x, @y, 200, 200) 
			@x += Gosu.offset_x(1, SPEED)
			@y += Gosu.offset_y(1, SPEED)
		end
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