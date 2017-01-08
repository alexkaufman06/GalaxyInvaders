require 'gosu'
require_relative 'player'
require_relative 'enemy'
require_relative 'boss-1'
require_relative 'bullet'
require_relative 'missile'
require_relative 'enemy-bullet'
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
		@hand_image = Gosu::Image.new('images/hand.png')
		@scene = :start
		@start_music = Gosu::Song.new('sounds/Lost Frontier.ogg')
		@level = 1
		@shield_hp = 100
		@galaxy_hp = 100
		@machine_gun = 0
		@shotgun = 0
		@missile = 0
		@fire_rate = 0.5
		@money = 0
		@max_enemies = 10
		@total_enemies_destroyed = 0
		@enemy_frequency = 0.01
		@font = Gosu::Font.new(20)
		@large_font = Gosu::Font.new(60)
		@white = Gosu::Color::WHITE
	end

	def initialize_game
		@player = Player.new(self)
		@enemies = []
		@bullets = []
		@enemy_bullets = []
		@missiles = []
		@explosions = []
		####################################### Colors for HP/FF Display #######################################
		@intruder_alert_color = Gosu::Color::NONE
		@health_color = Gosu::Color::GREEN
		@repair_hp_color = @white
		@repair_ff_color = @white
		@upgrade_mg_color = @white
		@upgrade_sg_color = @white
		@upgrade_hm_color = @white
		@shield_color = Gosu::Color::BLUE
		@machine_gun_color = Gosu::Color::RED
		@shotgun_color = Gosu::Color::RED
		@missile_color = Gosu::Color::RED
		@scene = :game
		@hit_by_bullet = false
		@enemies_appeared = 0
		@enemy_intruders = 0
		@enemies_destroyed = 0
		@seconds_played = 0
		@bullet_fired = Time.now
		@shotgun_fired = Time.now
		@missile_fired = Time.now                           
		#################################### Sounds and background music #######################################
		@game_music = Gosu::Song.new('sounds/Cephalopod.ogg')
		@start_music.play(true)
		@explosion_sound = Gosu::Sample.new('sounds/explosion.ogg')
		@shooting_sound = Gosu::Sample.new('sounds/shoot.ogg')
		@enemy_shooting_sound = Gosu::Sample.new('sounds/enemy-shoot.wav')
		@intruder_sound = Gosu::Sample.new('sounds/intruder-alert.wav')
		@engine_sound = Gosu::Sample.new('sounds/engine.wav')
		@cash_register_sound = Gosu::Sample.new('sounds/cash-register.wav')
		@shotgun_sound = Gosu::Sample.new('sounds/shotgun.wav')
		@missile_sound = Gosu::Sample.new('sounds/missile.wav')
	end

	def initialize_warning
		@scene = :boss_warning
		@warning_sound = Gosu::Song.new('sounds/warning.wav')
		@boss_1_sound = Gosu::Song.new('sounds/boss-loop.wav')
		@boss_fired = Time.now 
		@enemies.push Boss_1.new(self, @player)
		@boss_1 = @enemies[0]
		@warning_sound.play(true)
	end

	def draw
		case @scene
		when :start
			draw_start
		when :game
			draw_game
		when :level_up
			draw_level_up
		when :boss_warning
			draw_boss_warning
		when :boss_1_killed
			draw_boss_1_killed
		when :boss_1
			draw_boss_1
		when :end
			draw_end
		end
	end

	def draw_start
		@background_image.draw(0,0,0)
	end

	def draw_game
		############################# Covers screen when attacked and draws player #############################
		draw_quad(0, 0, @intruder_alert_color, 800, 0, @intruder_alert_color, 800, 600, @intruder_alert_color, 0, 600, @intruder_alert_color)
		@player.draw
		################################## Draw Enemy, Bullets and Explosions ##################################
		@enemies.each do |enemy|
			enemy.draw
		end         
		@bullets.each do |bullet|
			bullet.draw
		end
		@missiles.each do |missile|
			missile.draw
		end
		@explosions.each do |explosion|
			explosion.draw           
		end
		@enemy_bullets.each do |bullet|
			bullet.draw
		end
		######################################### Labels for display ##########################################
		@font.draw("HP", 5, 14, 2)
		@font.draw("FF", 5, 35, 2)
		@font.draw("$#{@money}", 5, 55, 2)
		######################################### Testing logic below #########################################
		# @font.draw("Dest: #{@enemies_destroyed}", 5, 120, 2)
		# @font.draw("App: #{@enemies_appeared}", 5, 70, 2)
		# @font.draw("#{@seconds_played}",5, 95, 2)
		# @font.draw("#{@total_enemies_destroyed}", 5, 90, 2)
		########################################### Health Display ###########################################
		draw_quad(35, 20, @health_color, 35 + @galaxy_hp, 20, @health_color, 35 + @galaxy_hp, 30, @health_color, 35, 30, @health_color)
		draw_line(35,20,Gosu::Color::WHITE,135,20,Gosu::Color::WHITE)
		draw_line(135,20,Gosu::Color::WHITE,135,30,Gosu::Color::WHITE)
		draw_line(135,30,Gosu::Color::WHITE,35,30,Gosu::Color::WHITE)
		draw_line(35,30,Gosu::Color::WHITE,35,20,Gosu::Color::WHITE)
		########################################### Shield Display ###########################################
		draw_quad(35, 40, @shield_color, 35 + @shield_hp, 40, @shield_color, 35 + @shield_hp, 50, @shield_color, 35, 50, @shield_color)
		draw_line(35,40,Gosu::Color::WHITE,135,40,Gosu::Color::WHITE)
		draw_line(135,40,Gosu::Color::WHITE,135,50,Gosu::Color::WHITE)
		draw_line(135,50,Gosu::Color::WHITE,35,50,Gosu::Color::WHITE)
		draw_line(35,50,Gosu::Color::WHITE,35,40,Gosu::Color::WHITE)
	end

	def update
		case @scene
		when :game
			update_game
		when :boss_warning
			update_boss_warning
		when :boss_1_killed
			update_boss_1_killed
		when :boss_1
			update_boss_1
		when :end
			update_end
		end
	end

	def draw_boss_warning
		@start_music.stop
		@large_font.draw("Boss Incoming", 200, 45, 1,1,1, Gosu::Color::RED)
		@font.draw("Press P to continue playing", 275, 250, 1,1,1, Gosu::Color::GREEN)
		@warning_sound.play(true)
	end

	def draw_boss_1_killed
		@start_music.stop
		@large_font.draw("Boss Destroyed", 200, 45, 1,1,1, Gosu::Color::RED)
		@font.draw("Press P to continue playing", 275, 250, 1,1,1, Gosu::Color::GREEN)
		@hand_image.draw(mouse_x - 11, mouse_y - 13, 1)
		@font.draw("Money: $#{@money}", 350, 350, 2)
		@warning_sound.play(true)
		if Gosu.distance(mouse_x, mouse_y, 230, 435) < 20
			@repair_hp_color = Gosu::Color::GREEN
		else
			@repair_hp_color = @white
		end

		if Gosu.distance(mouse_x, mouse_y, 230, 480) < 20
			@repair_ff_color = Gosu::Color::GREEN
		else
			@repair_ff_color = @white
		end

		if Gosu.distance(mouse_x, mouse_y, 660, 435) < 20
			@upgrade_mg_color = Gosu::Color::GREEN
		else
			@upgrade_mg_color = @white
		end

		if Gosu.distance(mouse_x, mouse_y, 660, 477) < 20
			@upgrade_sg_color = Gosu::Color::GREEN
		else
			@upgrade_sg_color = @white
		end

		if Gosu.distance(mouse_x, mouse_y, 660, 519) < 20
			@upgrade_hm_color = Gosu::Color::GREEN
		else
			@upgrade_hm_color = @white
		end

		if @galaxy_hp > 60
			@health_color = Gosu::Color::GREEN
		elsif @galaxy_hp > 30
			@health_color = Gosu::Color::YELLOW
		else
			@health_color = Gosu::Color::RED
		end

		if @machine_gun > 60
			@machine_gun_color = Gosu::Color::GREEN
		elsif @machine_gun > 30
			@machine_gun_color = Gosu::Color::YELLOW
		else
			@machine_gun_color = Gosu::Color::RED
		end

		if @shotgun > 60
			@shotgun_color = Gosu::Color::GREEN
		elsif @shotgun > 30
			@shotgun_color = Gosu::Color::YELLOW
		else
			@shotgun_color = Gosu::Color::RED
		end

		if @missile > 60
			@missile_color = Gosu::Color::GREEN
		elsif @missile > 30
			@missile_color = Gosu::Color::YELLOW
		else
			@missile_color = Gosu::Color::RED
		end

		draw_line(0,400,@white,800,400,@white)

		@font.draw("HP", 50, 413, 2)
		if @galaxy_hp < 100 && @money >= 20
			@font.draw("REPAIR", 200, 414, 1, 1, 1, @repair_hp_color)
		end
		draw_quad(85, 420, @health_color, 85 + @galaxy_hp, 420, @health_color, 85 + @galaxy_hp, 430, @health_color, 85, 430, @health_color)
		draw_line(85,420,@white,185,420,@white)
		draw_line(185,420,@white,185,430,@white)
		draw_line(185,430,@white,85,430,@white)
		draw_line(85,430,@white,85,420,@white)

		@font.draw("FF", 50, 455, 2)
		if @shield_hp < 100 && @money >= 20
			@font.draw("REPAIR", 200, 455, 1, 1, 1, @repair_ff_color)
		end
		draw_quad(85, 460, @shield_color, 85 + @shield_hp, 460, @shield_color, 85 + @shield_hp, 470, @shield_color, 85, 470, @shield_color)
		draw_line(85,460,@white,185,460,@white)
		draw_line(185,460,@white,185,470,@white)
		draw_line(185,470,@white,85,470,@white)
		draw_line(85,470,@white,85,460,@white)

		@font.draw("Machine Gun", 360, 413, 2)
		if @machine_gun < 100 && @money >= 100 + (2.5 * @machine_gun)
			@font.draw("Upgrade", 620, 413, 1, 1, 1, @upgrade_mg_color)
			@font.draw("$#{(@machine_gun * 2.5) + 100}", 710, 413, 1, 1, 1, @upgrade_mg_color)
		elsif @machine_gun < 100 && @money < 100 + (2.5 * @machine_gun)
			@font.draw("$#{(@machine_gun * 2.5) + 100}", 620, 413, 1, 1, 1, Gosu::Color::RED)
		end
		draw_quad(500, 420, @machine_gun_color, 500 + @machine_gun, 420, @machine_gun_color, 500 + @machine_gun, 430, @machine_gun_color, 500, 430, @machine_gun_color)
		draw_line(500, 420,@white,600,420,@white)
		draw_line(600, 420,@white,600,430,@white)
		draw_line(600, 430,@white,500,430,@white)
		draw_line(500, 430,@white,500,420,@white)

		@font.draw("Shotgun", 360, 455, 2)
		if @shotgun < 100 && @money >= 150 + (2.5 * @shotgun)
			@font.draw("Upgrade", 620, 455, 1, 1, 1, @upgrade_sg_color)
			@font.draw("$#{(@shotgun * 2.5 + 150)}", 710, 455, 1, 1, 1, @upgrade_sg_color)
		elsif @shotgun < 100 && @money < 150 + (2.5 * @shotgun)
			@font.draw("$#{(@shotgun * 2.5) + 150}", 620, 455, 1, 1, 1, Gosu::Color::RED)
		end
		draw_quad(500, 462, @shotgun_color, 500 + @shotgun, 462, @shotgun_color, 500 + @shotgun, 472, @shotgun_color, 500, 472, @shotgun_color)
		draw_line(500, 462, @white, 600, 462, @white)
		draw_line(600, 462, @white, 600, 472, @white)
		draw_line(600, 472, @white, 500, 472, @white)
		draw_line(500, 472, @white, 500, 462, @white)

		@font.draw("Homing Missile", 360, 497, 2)
		if @missile < 100 && @money >= 200 + (2.5 * @missile)
			@font.draw("Upgrade", 620, 497, 1, 1, 1, @upgrade_hm_color)
			@font.draw("$#{@missile * 2.5 + 200}", 710, 497, 1, 1, 1, @upgrade_hm_color)
		elsif @shotgun < 100 && @money < 200 + (2.5 * @missile)
			@font.draw("$#{@missile * 2.5 + 200}", 620, 497, 1, 1, 1, Gosu::Color::RED)
		end
		draw_quad(500, 504, @missile_color, 500 + @missile, 504, @missile_color, 500 + @missile, 514, @missile_color, 500, 514, @missile_color)
		draw_line(500, 504, @white, 600, 504, @white)
		draw_line(600, 504, @white, 600, 514, @white)
		draw_line(600, 514, @white, 500, 514, @white)
		draw_line(500, 514, @white, 500, 504, @white)
	end

	def draw_boss_1
		@start_music.stop
		draw_quad(0, 0, @intruder_alert_color, 800, 0, @intruder_alert_color, 800, 600, @intruder_alert_color, 0, 600, @intruder_alert_color)
		@boss_1_sound.play(true)
		@player.draw
		@enemies.each do |enemy|
			enemy.draw
		end  
		@bullets.each do |bullet|
			bullet.draw
		end
		@missiles.each do |missile|
			missile.draw
		end
		@enemy_bullets.each do |enemy_bullet|
			enemy_bullet.draw
		end
		@explosions.each do |explosion|
			explosion.draw           
		end 
		######################################### Labels for display ##########################################
		@font.draw("HP", 5, 14, 2)
		@font.draw("FF", 5, 35, 2)
		@font.draw("$#{@money}", 5, 55, 2)
		########################################### Health Display ###########################################
		draw_quad(35, 20, @health_color, 35 + @galaxy_hp, 20, @health_color, 35 + @galaxy_hp, 30, @health_color, 35, 30, @health_color)
		draw_line(35,20,Gosu::Color::WHITE,135,20,Gosu::Color::WHITE)
		draw_line(135,20,Gosu::Color::WHITE,135,30,Gosu::Color::WHITE)
		draw_line(135,30,Gosu::Color::WHITE,35,30,Gosu::Color::WHITE)
		draw_line(35,30,Gosu::Color::WHITE,35,20,Gosu::Color::WHITE)
		########################################### Shield Display ###########################################
		draw_quad(35, 40, @shield_color, 35 + @shield_hp, 40, @shield_color, 35 + @shield_hp, 50, @shield_color, 35, 50, @shield_color)
		draw_line(35,40,Gosu::Color::WHITE,135,40,Gosu::Color::WHITE)
		draw_line(135,40,Gosu::Color::WHITE,135,50,Gosu::Color::WHITE)
		draw_line(135,50,Gosu::Color::WHITE,35,50,Gosu::Color::WHITE)
		draw_line(35,50,Gosu::Color::WHITE,35,40,Gosu::Color::WHITE)
	end

	def update_boss_1
		@player.turn_left if button_down?(Gosu::KbLeft)
		@player.turn_right if button_down?(Gosu::KbRight)
		if button_down?(Gosu::KbUp)
			@player.accelerate
			@engine_sound.play(volume = 0.3, speed = 1, looping = false)
		end
		if button_down?(Gosu::KbDown)
			@player.reverse
			@engine_sound.play(volume = 0.3, speed = 1, looping = false)
		end
		####################### Move player, seconds played, and intruder color for flash ######################
		@seconds_played = (Time.now - START_TIME).to_i
		@player.move
		@enemies.each do |enemy|
			enemy.move
		end
		@bullets.each do |bullet|
			bullet.move
		end
		@missiles.each do |missile|
			missile.move
		end
		@enemy_bullets.each do |enemy_bullet|
			enemy_bullet.move
		end
		@bullets.dup.each do |bullet|
			@bullets.delete bullet unless bullet.onscreen?
		end		
		@missiles.dup.each do |missile|
			@missiles.delete missile unless missile.onscreen?
		end
		@enemy_bullets.dup.each do |bullet|
			@bullets.delete bullet unless bullet.onscreen?
		end
		########################################## Randomized enemies ##########################################
		if rand < 0.008
			@enemies.push Enemy.new(self, @level)
			@enemies_appeared += 1
		end
		##################################### Boss shooting logic below ########################################
		if (@enemies[0].x - @player.x).abs < 60 && (Time.now - @boss_fired) >= 0.75
		############################# Remove Timing logic above for Lazer Logic ################################
			@enemy_bullets.push Enemy_Bullet.new(self, (@enemies[0].x + 15), (@enemies[0].y + 45), 180, @level)
			@enemy_bullets.push Enemy_Bullet.new(self, (@enemies[0].x - 15), (@enemies[0].y + 45), 180, @level)			
			@enemy_bullets.push Enemy_Bullet.new(self, (@enemies[0].x + 40), (@enemies[0].y + 30), 180, @level)
			@enemy_bullets.push Enemy_Bullet.new(self, (@enemies[0].x - 40), (@enemies[0].y + 30), 180, @level)
			@enemy_shooting_sound.play(0.3)
			@boss_fired = Time.now
		end
		############################### Collision detection for boss and bullets ###############################
			@bullets.dup.each do |bullet|
				distance = Gosu.distance(@boss_1.x, @boss_1.y, bullet.x, bullet.y)
				if distance < @boss_1.radius + bullet.radius
					@boss_1.hit_by_bullet
					@bullets.delete bullet
					@explosions.push Explosion.new(self, bullet.x, bullet.y)
					@explosion_sound.play
				end
			end
		############################# Collision detection for enemies and bullets ###############################
		@enemies.dup.each do |enemy|
			@bullets.dup.each do |bullet|
				distance = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
				if distance < enemy.radius + bullet.radius
					@enemies.delete enemy
					@bullets.delete bullet
					@explosions.push Explosion.new(self, enemy.x, enemy.y)
					@enemies_destroyed += 1
					@total_enemies_destroyed += 1
					@money += 10
					@explosion_sound.play
				end 
			end
		end
		############################# Collision detection for boss and missiles ##############################
		@missiles.dup.each do |missile|
			distance = Gosu.distance(@boss_1.x, @boss_1.y, missile.x, missile.y)
			if distance < @boss_1.radius + missile.radius
				@boss_1.hit_by_missile
				@missiles.delete missile
				@explosions.push Explosion.new(self, @boss_1.x, @boss_1.y)
				@explosion_sound.play
			end 
		end
		############################# Collision detection for enemies and missiles ##############################
		@enemies.dup.each do |enemy|
			@missiles.dup.each do |missile|
				distance = Gosu.distance(enemy.x, enemy.y, missile.x, missile.y)
				if distance < enemy.radius + missile.radius
					@enemies.delete enemy
					@missiles.delete missile
					@explosions.push Explosion.new(self, enemy.x, enemy.y)
					@enemies_destroyed += 1
					@total_enemies_destroyed += 1
					@money += 10
					@explosion_sound.play
				end 
			end
		end
		############################## Remove explosions, enemies, and bullets #################################
		@explosions.dup.each do |explosion|
			@explosions.delete explosion if explosion.finished
		end
		@enemies.dup.each do|enemy|
			if enemy.y > HEIGHT + enemy.radius
				@enemies.delete enemy
				@enemy_intruders += 1;
				@galaxy_hp -= 10;                
				@intruder_alert_color = Gosu::Color::RED
				@intruder_sound.play
			end
		end
		@bullets.dup.each do |bullet|
			@bullets.delete bullet unless bullet.onscreen?
		end		
		@missiles.dup.each do |missile|
			@missiles.delete missile unless missile.onscreen?
		end
		@enemy_bullets.dup.each do |bullet|
			@bullets.delete bullet unless bullet.onscreen?
		end
		############################# Collision detection for enemies and player ###############################
		@enemies.each do |enemy|
			distance = Gosu.distance(enemy.x, enemy.y, @player.x, @player.y)
			if distance < @player.radius + enemy.radius && @shield_hp > 0 && enemy == @boss_1
				initialize_end(:crash_into_boss)
			elsif distance < @player.radius + enemy.radius && @shield_hp > 0
				@enemies.delete enemy
				@explosions.push Explosion.new(self, enemy.x, enemy.y)
				@explosion_sound.play
				@total_enemies_destroyed += 1
				@enemies_destroyed += 1
				@money += 10
				@shield_hp -= 10
			elsif distance < @player.radius + enemy.radius
				@explosions.push Explosion.new(self, @player.x, @player.y)
				@explosion_sound.play
				@player.explode
			end
		end
		########################### Collision detection for player and enemy bullets ############################
		@enemy_bullets.dup.each do |enemy_bullet|
			distance = Gosu.distance(enemy_bullet.x, enemy_bullet.y, @player.x, @player.y)
			if distance < enemy_bullet.radius + @player.radius && @shield_hp > 0
				@enemy_bullets.delete enemy_bullet
				@explosions.push Explosion.new(self, enemy_bullet.x, enemy_bullet.y)
				@explosion_sound.play
				@shield_hp -= 10
			elsif distance < enemy_bullet.radius + @player.radius
				@explosions.push Explosion.new(self, @player.x, @player.y)
				@enemy_bullets.delete enemy_bullet
				@explosion_sound.play
				@total_enemies_destroyed += 1
				@player.explode
				@hit_by_bullet = true
			end
		end
		################################# Logic for machine gun and shot gun ##################################
		#Highest fire rate = 0.04
		if button_down?(Gosu::KbSpace) && (Time.now - @bullet_fired) >= @fire_rate
			if @shotgun == 10 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@shotgun_sound.play
			elsif @shotgun == 20 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 30 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 40 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 50 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 60 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 70 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 20))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 80 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 20))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 20))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 90 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 25))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 20))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 20))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 100 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 25))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 25))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 20))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 20))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			end
		####################################### Logic for machine gun  ########################################
			@bullet_fired = Time.now  
			@bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
			@shooting_sound.play(0.3)
		end
		##################################### Logic for homing missiles  ######################################
		if button_down?(Gosu::KbSpace) && (Time.now - @missile_fired) >= (2 - (@missile / 100)) && @enemies.count != 0 && @missile != 0
			@missile_fired = Time.now
			@missiles.push Missile.new(self, @player.x, @player.y, @player.angle, @enemies)
			@missile_sound.play
		end
		@enemies.each do |enemy|
			if rand < 0.005 && enemy != @enemies[0]
				@enemy_bullets.push Enemy_Bullet.new(self, enemy.x, enemy.y, 180, @level)
				@enemy_shooting_sound.play(0.3)
			end
		end
		########################################## Scene transitions ###########################################
		if @boss_1.hp <= 0
			@money += 300
			@scene = :boss_1_killed
		end
		initialize_end(:hit_by_bullet) if @player.exploded && @hit_by_bullet
		initialize_end(:hit_by_enemy) if @player.exploded && !@hit_by_bullet
		initialize_end(:too_many_intruders) if @galaxy_hp == 0
		initialize_end(:off_top) if @player.y < @player.radius
	end

	def update_boss_warning

	end

	def update_boss_1_killed

	end

	def update_game
		########################################## Spaceship controls ##########################################
		@player.turn_left if button_down?(Gosu::KbLeft)
		@player.turn_right if button_down?(Gosu::KbRight)
		if button_down?(Gosu::KbUp)
			@player.accelerate
			@engine_sound.play(volume = 0.3, speed = 1, looping = false)
		end
		if button_down?(Gosu::KbDown)
			@player.reverse
			@engine_sound.play(volume = 0.3, speed = 1, looping = false)
		end
		####################### Move player, seconds played, and intruder color for flash ######################
		@seconds_played = (Time.now - START_TIME).to_i
		@player.move
		@intruder_alert_color = Gosu::Color::NONE
		########################################## Randomized enemies ##########################################
		if rand < @enemy_frequency && @max_enemies > @enemies_appeared
			@enemies.push Enemy.new(self, @level)
			@enemies_appeared += 1
		end
		####################################### Move enemies and bullets #######################################
		@enemies.each do |enemy|
			enemy.move
		end
		@bullets.each do |bullet|
			bullet.move
		end
		@missiles.each do |missile|
			missile.move
		end
		@enemy_bullets.each do |bullet|
			bullet.move
		end
  	############################# Collision detection for enemies and bullets ##############################
		@enemies.dup.each do |enemy|
			@bullets.dup.each do |bullet|
				distance = Gosu.distance(enemy.x, enemy.y, bullet.x, bullet.y)
				if distance < enemy.radius + bullet.radius
					@enemies.delete enemy
					@bullets.delete bullet
					@explosions.push Explosion.new(self, enemy.x, enemy.y)
					@enemies_destroyed += 1
					@total_enemies_destroyed += 1
					@money += 10
					@explosion_sound.play
				end 
			end
		end  	
		############################# Collision detection for enemies and missiles ##############################
		@enemies.dup.each do |enemy|
			@missiles.dup.each do |missile|
				distance = Gosu.distance(enemy.x, enemy.y, missile.x, missile.y)
				if distance < enemy.radius + missile.radius
					@enemies.delete enemy
					@missiles.delete missile
					@explosions.push Explosion.new(self, enemy.x, enemy.y)
					@enemies_destroyed += 1
					@total_enemies_destroyed += 1
					@money += 10
					@explosion_sound.play
				end 
			end
		end
		############################## Remove explosions, enemies, and bullets #################################
		@explosions.dup.each do |explosion|
			@explosions.delete explosion if explosion.finished
		end
		@enemies.dup.each do|enemy|
			if enemy.y > HEIGHT + enemy.radius
				@enemies.delete enemy
				@enemy_intruders += 1;
				@galaxy_hp -= 10;                
				@intruder_alert_color = Gosu::Color::RED
				@intruder_sound.play
			end
		end
		@bullets.dup.each do |bullet|
			@bullets.delete bullet unless bullet.onscreen?
		end		
		@missiles.dup.each do |missile|
			@missiles.delete missile unless missile.onscreen?
		end
		@enemy_bullets.dup.each do |bullet|
			@bullets.delete bullet unless bullet.onscreen?
		end		
		####################################### Colors for HP/FF Display #######################################
		if @galaxy_hp > 60
			@health_color = Gosu::Color::GREEN
		elsif @galaxy_hp > 30
			@health_color = Gosu::Color::YELLOW
		else
			@health_color = Gosu::Color::RED
		end	
		########################################## Scene transitions ###########################################
		@scene = :level_up if @enemy_intruders + @enemies_destroyed >= @max_enemies
		initialize_end(:hit_by_bullet) if @player.exploded && @hit_by_bullet
		initialize_end(:hit_by_enemy) if @player.exploded && !@hit_by_bullet
		initialize_end(:too_many_intruders) if @galaxy_hp == 0
		# @scene = :boss_warning if @level == 1 && @enemy_intruders + @enemies_destroyed >= @max_enemies
		############################# Collision detection for enemies and player ###############################
		@enemies.each do |enemy|
			distance = Gosu.distance(enemy.x, enemy.y, @player.x, @player.y)
			if distance < @player.radius + enemy.radius && @shield_hp > 0
				@enemies.delete enemy
				@explosions.push Explosion.new(self, enemy.x, enemy.y)
				@explosion_sound.play
				@total_enemies_destroyed += 1
				@enemies_destroyed += 1
				@money += 10
				@shield_hp -= 10
			elsif distance < @player.radius + enemy.radius
				@explosions.push Explosion.new(self, @player.x, @player.y)
				@explosion_sound.play
				@player.explode
			end
		end
		########################### Collision detection for player and enemy bullets ############################
		@enemy_bullets.dup.each do |enemy_bullet|
			distance = Gosu.distance(enemy_bullet.x, enemy_bullet.y, @player.x, @player.y)
			if distance < enemy_bullet.radius + @player.radius && @shield_hp > 0
				@enemy_bullets.delete enemy_bullet
				@explosions.push Explosion.new(self, enemy_bullet.x, enemy_bullet.y)
				@explosion_sound.play
				@shield_hp -= 10
			elsif distance < enemy_bullet.radius + @player.radius
				@explosions.push Explosion.new(self, @player.x, @player.y)
				@enemy_bullets.delete enemy_bullet
				@explosion_sound.play
				@total_enemies_destroyed += 1
				@player.explode
				@hit_by_bullet = true
			end
		end
		################################# Logic for machine gun and shot gun ##################################
		#Highest fire rate = 0.04
		if button_down?(Gosu::KbSpace) && (Time.now - @bullet_fired) >= @fire_rate
			if @shotgun == 10 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@shotgun_sound.play
			elsif @shotgun == 20 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 30 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 40 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 50 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 60 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 70 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 20))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 80 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 20))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 20))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 90 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 25))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 20))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 20))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			elsif @shotgun == 100 && (Time.now - @shotgun_fired) >= 1.5
				@shotgun_fired = Time.now
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 25))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 25))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 20))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 20))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 15))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 10))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle + 5))
				@bullets.push Bullet.new(self, @player.x, @player.y, (@player.angle - 5))
				@shotgun_sound.play
			end
		####################################### Logic for machine gun  ########################################
			@bullet_fired = Time.now  
			@bullets.push Bullet.new(self, @player.x, @player.y, @player.angle)
			@shooting_sound.play(0.3)
		end

		@enemies.each do |enemy|
			if @level > 2 && rand < 0.003
				@enemy_bullets.push Enemy_Bullet.new(self, enemy.x, enemy.y, 180, @level)
				@enemy_shooting_sound.play(0.3)
			end
		end

		##################################### Logic for homing missiles  ######################################
		if button_down?(Gosu::KbSpace) && (Time.now - @missile_fired) >= (2 - (@missile / 100)) && @enemies.count != 0 && @missile != 0
			@missile_fired = Time.now
			@missiles.push Missile.new(self, @player.x, @player.y, @player.angle, @enemies)
			@missile_sound.play
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
		when :boss_warning
			button_down_boss_warning(id)
		when :boss_1_killed
			button_down_boss_1_killed(id)
		when :end
			button_down_end(id)
		end
	end

	def button_down_start(id)
		initialize_game
	end

	def button_down_boss_1_killed(id)
		if id == Gosu::KbP
			@start_music.play(true)
			@level += 1
			@max_enemies += 5
			@enemy_frequency += 0.002
			initialize_game
		end

		if (id == Gosu::MsLeft) && @galaxy_hp != 100 && @money >= 20
			if Gosu.distance(mouse_x, mouse_y, 230, 435) < 20
				@galaxy_hp += 10
				@money -= 20
				@cash_register_sound.play
			end
		end

		if (id == Gosu::MsLeft) && @shield_hp != 100 && @money >= 20
			if Gosu.distance(mouse_x, mouse_y, 230, 480) < 20
				@shield_hp += 10
				@money -= 20
				@cash_register_sound.play
			end
		end

		if (id == Gosu::MsLeft) && @machine_gun != 100 && @money >= 100 + (2.5 * @machine_gun)
			if Gosu.distance(mouse_x, mouse_y, 660, 435) < 20
				@money -= 100 + (2.5 * @machine_gun)
				@machine_gun += 10
				@fire_rate -= 0.046
				@cash_register_sound.play 
			end
		end

		if (id == Gosu::MsLeft) && @shot_gun != 100 && @money >= 150 + (2.5 * @shotgun)
			if Gosu.distance(mouse_x, mouse_y, 660, 477) < 20
				@money -= 150 + (2.5 * @shotgun)
				@shotgun += 10
				@cash_register_sound.play
			end
		end

		if (id == Gosu::MsLeft) && @missile != 100 && @money >= 200 + (2.5 * @missile)
			if Gosu.distance(mouse_x, mouse_y, 660, 519) < 20
				@money -= 200 + (2.5 * @missile)
				@missile += 10
				@cash_register_sound.play
			end
		end	
	end

	def button_down_boss_warning(id)
		if id == Gosu::KbP
			@scene = :boss_1
			@start_music.play(true)
		end
	end

	def button_down_level_up(id)
		if id == Gosu::KbP && @level == 5
			initialize_warning
		elsif	id == Gosu::KbP
			@level += 1
			@max_enemies += 5
			@enemy_frequency += 0.002
			initialize_game
		end

		if (id == Gosu::MsLeft) && @galaxy_hp != 100 && @money >= 20
			if Gosu.distance(mouse_x, mouse_y, 230, 435) < 20
				@galaxy_hp += 10
				@money -= 20
				@cash_register_sound.play
			end
		end

		if (id == Gosu::MsLeft) && @shield_hp != 100 && @money >= 20
			if Gosu.distance(mouse_x, mouse_y, 230, 480) < 20
				@shield_hp += 10
				@money -= 20
				@cash_register_sound.play
			end
		end

		if (id == Gosu::MsLeft) && @machine_gun != 100 && @money >= 100 + (2.5 * @machine_gun)
			if Gosu.distance(mouse_x, mouse_y, 660, 435) < 20
				@money -= 100 + (2.5 * @machine_gun)
				@machine_gun += 10
				@fire_rate -= 0.046
				@cash_register_sound.play 
			end
		end

		if (id == Gosu::MsLeft) && @shot_gun != 100 && @money >= 150 + (2.5 * @shotgun)
			if Gosu.distance(mouse_x, mouse_y, 660, 477) < 20
				@money -= 150 + (2.5 * @shotgun)
				@shotgun += 10
				@cash_register_sound.play
			end
		end

		if (id == Gosu::MsLeft) && @missile != 100 && @money >= 200 + (2.5 * @missile)
			if Gosu.distance(mouse_x, mouse_y, 660, 519) < 20
				@money -= 200 + (2.5 * @missile)
				@missile += 10
				@cash_register_sound.play
			end
		end	
	end

	def button_down_game(id)

	end

	def draw_level_up
		if Gosu.distance(mouse_x, mouse_y, 230, 435) < 20
			@repair_hp_color = Gosu::Color::GREEN
		else
			@repair_hp_color = @white
		end

		if Gosu.distance(mouse_x, mouse_y, 230, 480) < 20
			@repair_ff_color = Gosu::Color::GREEN
		else
			@repair_ff_color = @white
		end

		if Gosu.distance(mouse_x, mouse_y, 660, 435) < 20
			@upgrade_mg_color = Gosu::Color::GREEN
		else
			@upgrade_mg_color = @white
		end

		if Gosu.distance(mouse_x, mouse_y, 660, 477) < 20
			@upgrade_sg_color = Gosu::Color::GREEN
		else
			@upgrade_sg_color = @white
		end

		if Gosu.distance(mouse_x, mouse_y, 660, 519) < 20
			@upgrade_hm_color = Gosu::Color::GREEN
		else
			@upgrade_hm_color = @white
		end

		@large_font.draw("You completed level " + @level.to_s, 120, 45, 2)
		@font.draw("You destroyed " + @enemies_destroyed.to_s + " enemy ships", 250, 110, 2)
		@font.draw(@enemy_intruders.to_s + " enemies invaded your galaxy", 250, 135, 2)
		@font.draw("Press P to continue playing", 275, 250, 1,1,1, Gosu::Color::GREEN)
		@hand_image.draw(mouse_x - 11, mouse_y - 13, 1)
		@font.draw("Money: $#{@money}", 350, 350, 2)

		if @galaxy_hp > 60
			@health_color = Gosu::Color::GREEN
		elsif @galaxy_hp > 30
			@health_color = Gosu::Color::YELLOW
		else
			@health_color = Gosu::Color::RED
		end

		if @machine_gun > 60
			@machine_gun_color = Gosu::Color::GREEN
		elsif @machine_gun > 30
			@machine_gun_color = Gosu::Color::YELLOW
		else
			@machine_gun_color = Gosu::Color::RED
		end

		if @shotgun > 60
			@shotgun_color = Gosu::Color::GREEN
		elsif @shotgun > 30
			@shotgun_color = Gosu::Color::YELLOW
		else
			@shotgun_color = Gosu::Color::RED
		end

		if @missile > 60
			@missile_color = Gosu::Color::GREEN
		elsif @missile > 30
			@missile_color = Gosu::Color::YELLOW
		else
			@missile_color = Gosu::Color::RED
		end

		draw_line(0,400,@white,800,400,@white)

		@font.draw("HP", 50, 413, 2)
		if @galaxy_hp < 100 && @money >= 20
			@font.draw("REPAIR", 200, 414, 1, 1, 1, @repair_hp_color)
		end
		draw_quad(85, 420, @health_color, 85 + @galaxy_hp, 420, @health_color, 85 + @galaxy_hp, 430, @health_color, 85, 430, @health_color)
		draw_line(85,420,@white,185,420,@white)
		draw_line(185,420,@white,185,430,@white)
		draw_line(185,430,@white,85,430,@white)
		draw_line(85,430,@white,85,420,@white)

		@font.draw("FF", 50, 455, 2)
		if @shield_hp < 100 && @money >= 20
			@font.draw("REPAIR", 200, 455, 1, 1, 1, @repair_ff_color)
		end
		draw_quad(85, 460, @shield_color, 85 + @shield_hp, 460, @shield_color, 85 + @shield_hp, 470, @shield_color, 85, 470, @shield_color)
		draw_line(85,460,@white,185,460,@white)
		draw_line(185,460,@white,185,470,@white)
		draw_line(185,470,@white,85,470,@white)
		draw_line(85,470,@white,85,460,@white)

		@font.draw("Machine Gun", 360, 413, 2)
		if @machine_gun < 100 && @money >= 100 + (2.5 * @machine_gun)
			@font.draw("Upgrade", 620, 413, 1, 1, 1, @upgrade_mg_color)
			@font.draw("$#{(@machine_gun * 2.5) + 100}", 710, 413, 1, 1, 1, @upgrade_mg_color)
		elsif @machine_gun < 100 && @money < 100 + (2.5 * @machine_gun)
			@font.draw("$#{(@machine_gun * 2.5) + 100}", 620, 413, 1, 1, 1, Gosu::Color::RED)
		end
		draw_quad(500, 420, @machine_gun_color, 500 + @machine_gun, 420, @machine_gun_color, 500 + @machine_gun, 430, @machine_gun_color, 500, 430, @machine_gun_color)
		draw_line(500, 420,@white,600,420,@white)
		draw_line(600, 420,@white,600,430,@white)
		draw_line(600, 430,@white,500,430,@white)
		draw_line(500, 430,@white,500,420,@white)

		@font.draw("Shotgun", 360, 455, 2)
		if @shotgun < 100 && @money >= 150 + (2.5 * @shotgun)
			@font.draw("Upgrade", 620, 455, 1, 1, 1, @upgrade_sg_color)
			@font.draw("$#{(@shotgun * 2.5 + 150)}", 710, 455, 1, 1, 1, @upgrade_sg_color)
		elsif @shotgun < 100 && @money < 150 + (2.5 * @shotgun)
			@font.draw("$#{(@shotgun * 2.5) + 150}", 620, 455, 1, 1, 1, Gosu::Color::RED)
		end
		draw_quad(500, 462, @shotgun_color, 500 + @shotgun, 462, @shotgun_color, 500 + @shotgun, 472, @shotgun_color, 500, 472, @shotgun_color)
		draw_line(500, 462, @white, 600, 462, @white)
		draw_line(600, 462, @white, 600, 472, @white)
		draw_line(600, 472, @white, 500, 472, @white)
		draw_line(500, 472, @white, 500, 462, @white)

		@font.draw("Homing Missile", 360, 497, 2)
		if @missile < 100 && @money >= 200 + (2.5 * @missile)
			@font.draw("Upgrade", 620, 497, 1, 1, 1, @upgrade_hm_color)
			@font.draw("$#{@missile * 2.5 + 200}", 710, 497, 1, 1, 1, @upgrade_hm_color)
		elsif @shotgun < 100 && @money < 200 + (2.5 * @missile)
			@font.draw("$#{@missile * 2.5 + 200}", 620, 497, 1, 1, 1, Gosu::Color::RED)
		end
		draw_quad(500, 504, @missile_color, 500 + @missile, 504, @missile_color, 500 + @missile, 514, @missile_color, 500, 514, @missile_color)
		draw_line(500, 504, @white, 600, 504, @white)
		draw_line(600, 504, @white, 600, 514, @white)
		draw_line(600, 514, @white, 500, 514, @white)
		draw_line(500, 514, @white, 500, 504, @white)	

		if @level == 2
			@font.draw("Watch out! Enemies can now shoot at you.",225,200,1,1,1,Gosu::Color::RED)
		end
	end

	def initialize_end(fate)
		case fate
		when :hit_by_enemy
			@message = "You were struck by an enemy ship at level #{@level}."
			@message2 = "Before your ship was destroyed, "
			@message2 += "you took out #{@total_enemies_destroyed} enemy ships."
		when :hit_by_bullet
			@message = "You were struck by enemy fire at level #{@level}."
			@message2 = "Before your ship was destroyed, "
			@message2 += "you took out #{@total_enemies_destroyed} enemy ships."
		when :too_many_intruders
			@message = "You let too many intruders invade our galaxy at level #{@level}."
			@message2 = "Before the galaxy was invaded, "
			@message2 += "you destroyed #{@total_enemies_destroyed} enemy ships."
		when :off_top
			@message = "You got too close to the enemy mother ship at level #{@level}."
			@message2 = "Before your ship was destroyed, "
			@message2 += "you took out #{@total_enemies_destroyed} enemy ships."
		when :crash_into_boss
		@message = "You got too close to the boss ship at level #{@level}."
		@message2 = "Before your ship was destroyed, "
		@message2 += "you took out #{@total_enemies_destroyed} enemy ships."
		end
		@bottom_message = "Press P to play again, or Q to quit."
		@message_font = Gosu::Font.new(25)
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