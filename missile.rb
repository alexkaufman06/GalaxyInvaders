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
		@nearest_enemy = enemies[0]
		@enemies = enemies
	end

	def move
		@nearest_enemy_distance = 1000
		@distance = 0
		@distance_nearest = 0
		@enemies.each do |enemy|
			@distance = Gosu.distance(enemy.x, enemy.y, @x, @y)
			@distance_nearest = Gosu.distance(@nearest_enemy.x, @nearest_enemy.y, @x, @y)
			if @distance < @distance_nearest
				@nearest_enemy = enemy
			end 
		end
		@homing_angle = Gosu.angle(@x, @y, @nearest_enemy.x, @nearest_enemy.y)
		@x += Gosu.offset_x(@homing_angle, SPEED)
		@y += Gosu.offset_y(@homing_angle, SPEED)
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