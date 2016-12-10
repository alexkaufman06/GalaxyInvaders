require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'explosion'
require_relative 'credit'

class GalaxyInvaders < Gosu::Window
	WIDTH = 800
	HEIGHT = 600
	START_TIME = Time.now

	def initialize
		super(WIDTH, HEIGHT)
		self.caption = 'Galaxy Invaders'
		@background_image = Gosu::Image.new('images/start.png')
		@scene = :start
		@start_music = Gosu::Song.new('sounds/Lost Frontier.ogg')
		@level = 1
		@max_enemies = 10
		@total_enemies_destroyed = 0
		@enemy_frequency = 0.01
		@font = Gosu::Font.new(20)
		@large_font = Gosu::Font.new(60)
	end

	def initialize_game
		@player = Player.new(self)
		@enemies = []
		@bullets = []
		@explosions = []
		@color = Gosu::Color::NONE
		@health = Gosu::Color::GREEN
		@scene = :game
		@pressed = false
		@enemies_appeared = 0
		@enemy_intruders = 0
		@enemies_destroyed = 0
		@seconds_played = 0
		@bullet_fired = Time.now
		@game_music = Gosu::Song.new('sounds/Cephalopod.ogg')
		@start_music.play(true)
		@explosion_sound = Gosu::Sample.new('sounds/explosion.ogg')
		@shooting_sound = Gosu::Sample.new('sounds/shoot.ogg')
		@intruder_sound = Gosu::Sample.new('sounds/intruder-alert.wav')
	end

	def draw
		case @scene
		when :start
			draw_start
		when :game
			draw_game
		when :level_up
			draw_level_up
		when :end
			draw_end
		end
	end

	def draw_start
		@background_image.draw(0,0,0)
	end

	def draw_game
		draw_quad(0, 0, @color, 800, 0, @color, 800, 600, @color, 0, 600, @color)
		@player.draw
		@enemies.each do |enemy|
			enemy.draw
		end  
		@bullets.each do |bullet|
			bullet.draw
		end
		@explosions.each do |explosion|
			explosion.draw
		end
		@font.draw("HP", 5, 20, 2)
		# @font.draw("Dest: #{@enemies_destroyed}", 5, 120, 2)
		# @font.draw("App: #{@enemies_appeared}", 5, 70, 2)
		# @font.draw("#{@seconds_played}",5, 95, 2)
		@font.draw("#{@total_enemies_destroyed}", 5, 90, 2)
		
		if @player.machine_gun == true
			@font.draw("MG", 5, 45, 2)
		end

		draw_quad(35, 20, @health, 135 - (@enemy_intruders * 10), 20, @health, 135 - (@enemy_intruders * 10), 40, @health, 35, 40, @health)
		draw_line(35,20,Gosu::Color::WHITE,135,20,Gosu::Color::WHITE)
		draw_line(135,20,Gosu::Color::WHITE,135,40,Gosu::Color::WHITE)
		draw_line(135,40,Gosu::Color::WHITE,35,40,Gosu::Color::WHITE)
		draw_line(35,40,Gosu::Color::WHITE,35,20,Gosu::Color::WHITE)
	end

	def update
		case @scene
		when :game
			update_game
		when :end
			update_end
		end
	end

	def update_game
		@player.turn_left if button_down?(Gosu::KbLeft)
		@player.turn_right if button_down?(Gosu::KbRight)
		@player.accelerate if button_down?(Gosu::KbUp)
		@player.reverse if button_down?(Gosu::KbDown)

		# if button_down?(Gosu::KbM)
		# 	@player.use_machine_gun
		# end

		@seconds_played = (Time.now - START_TIME).to_i

		@player.move
		@color = Gosu::Color::NONE

		if rand < @enemy_frequency && @max_enemies > @enemies_appeared
			@enemies.push Enemy.new(self, @level)

			@enemies_appeared += 1
		end

		@enemies.each do |enemy|
			enemy.move
		end

		@bullets.each do |bullet|
			bullet.move
		end 
  
		@enemies.dup.each do |enemy|
			@bullets.dup.each do |bullet|
				distance = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
				if distance < enemy.radius + bullet.radius
					@enemies.delete enemy
					@bullets.delete bullet
					@explosions.push Explosion.new(self, enemy.x, enemy.y)
					@enemies_destroyed += 1
					@total_enemies_destroyed += 1
					@explosion_sound.play
				end 
			end
		end

		@explosions.dup.each do |explosion|
			@explosions.delete explosion if explosion.finished
		end

		@enemies.dup.each do|enemy|
			if enemy.y > HEIGHT + enemy.radius
				@enemies.delete enemy
				@enemy_intruders += 1;
				@color = Gosu::Color::RED
				@intruder_sound.play
			end
		end

		@bullets.dup.each do |bullet|
			@bullets.delete bullet unless bullet.onscreen?
		end

		if @enemy_intruders > 6
			@health = Gosu::Color::RED
		elsif @enemy_intruders > 4
			@health = Gosu::Color::YELLOW
		else
			@health = Gosu::Color::GREEN
		end	

		@scene = :level_up if @enemy_intruders + @enemies_destroyed >= @max_enemies

		initialize_end(:hit_by_enemy) if @player.exploded

		initialize_end(:too_many_intruders) if @enemy_intruders > 9

		@enemies.each do |enemy|
			distance = Gosu.distance(enemy.x, enemy.y, @player.x, @player.y)
			if distance < @player.radius + enemy.radius
				@explosions.push Explosion.new(self, @player.x, @player.y)
				@explosion_sound.play
				@player.explode
			end
		end

		if @player.machine_gun == true && button_down?(Gosu::KbSpace) && (Time.now - @bullet_fired) >= 0.04
			@bullet_fired = Time.now  
			@bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
			@shooting_sound.play(0.3)
		end
		
		initialize_end(:off_top) if @player.y < @player.radius
	end

	def button_down(id)
		case @scene
		when :start
			button_down_start(id)
		when :game
			button_down_game(id)
		when :level_up
			button_down_level_up(id)
		when :end
			button_down_end(id)
		end
	end

	def button_down_start(id)
		initialize_game
	end

	def button_down_level_up(id)
		if id == Gosu::KbP
			@level += 1
			@max_enemies += 10
			@enemy_frequency += 0.0025
			initialize_game
		end	
	end

	def button_down_game(id)
		if id == Gosu::KbM && !@pressed
			@player.use_machine_gun
			@pressed = true
		elsif button_down?(Gosu::KbSpace) && @player.machine_gun != true
			@bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
			@shooting_sound.play(0.3)	
		elsif not id == Gosu::KbM
			@pressed = false
		end
	end

	def draw_level_up
		@large_font.draw("You completed level " + @level.to_s, 120, 45, 2)
		@font.draw("You destroyed " + @enemies_destroyed.to_s + " enemy ships", 250, 110, 2)
		@font.draw(@enemy_intruders.to_s + " enemies invaded your galaxy", 250, 135, 2)
		@font.draw("Press P to continue playing", 275, 350, 1,1,1, Gosu::Color::GREEN)
	end

	def initialize_end(fate)
		case fate
		when :hit_by_enemy
			@message = "You were struck by an enemy ship."
			@message2 = "Before your ship was destroyed, "
			@message2 += "you took out #{@total_enemies_destroyed} enemy ships."
		when :too_many_intruders
			@message = "You let too many intruders invade our galaxy."
			@message2 = "Before the galaxy was invaded, "
			@message2 += "you destroyed #{@total_enemies_destroyed} enemy ships."
		when :off_top
			@message = "You got too close to the enemy mother ship."
			@message2 = "Before your ship was destroyed, "
			@message2 += "you took out #{@total_enemies_destroyed} enemy ships."
		end
		@bottom_message = "Press P to play again, or Q to quit."
		@message_font = Gosu::Font.new(28)
		@credits = []
		y = 700
		File.open('credits.txt').each do |line|
			@credits.push(Credit.new(self,line.chomp,100,y))
			y+=30
		end
		@scene = :end
		@end_music = Gosu::Song.new('sounds/FromHere.ogg')
		@end_music.play(true)
	end

	def draw_end
		clip_to(50,140,700,360) do
			@credits.each do |credit|
				credit.draw
			end
		end
		draw_line(0,140,Gosu::Color::RED,WIDTH,140,Gosu::Color::RED)
		@message_font.draw(@message,40,40,1,1,1,Gosu::Color::GREEN)
		@message_font.draw(@message2,40,75,1,1,1,Gosu::Color::GREEN)
		draw_line(0,500,Gosu::Color::RED,WIDTH,500,Gosu::Color::RED)
		@message_font.draw(@bottom_message,180,540,1,1,1,Gosu::Color::RED)
	end

	def update_end
		@credits.each do |credit|
			credit.move
		end

		if @credits.last.y < 150
			@credits.each do |credit|
				credit.reset
			end
		end
	end

	def button_down_end(id)
		if id == Gosu::KbP
			initialize
			initialize_game
		elsif id == Gosu::KbQ
			close
		end
	end
end
window = GalaxyInvaders.new
window.show