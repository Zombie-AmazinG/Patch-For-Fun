/////////////////////////////////
//   PATCH BY ZOMBIE AMAZING   //
/////////////////////////////////

#include maps\_utility;
#include common_scripts\utility; 
#include maps\_zombiemode_utility;
#include maps\_hud_util;

init()
{
	replacefunc(maps\_zombiemode::round_think, ::custom_round_think);
	setDvar("player_backSpeedScale", 1);
	setDvar("player_strafeSpeedScale", 1);
	setDvar("player_sprintStrafeSpeedScale", 1);
	level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{
		level waittill("connected", player);
		player thread onPlayerSpawned();
	}
}

onPlayerSpawned()
{
	self endon("disconnect");
	self.initial_spawn = 1;
	for(;;)
	{
		self waittill("spawned_player");
		if (self.initial_spawn == 1)
		{
			self.initial_spawn = 0;
            self thread start_message();
			self thread lobby_timer();
			self thread round_timer();
			self thread reset_timer();
			self thread sph();
			self thread dog_tracker();
			self thread health();
			self thread zombie_counter();
			self thread box_hits();
			self thread score_box();
			self thread trap_timer_check();
			self thread zipline_check();
			self thread flogger_check();
			self thread trap_timer();
			self thread zipline_timer();
			self thread flogger_timer();
		}
	}
}

///////////////////
//  IGNORE THIS  //
///////////////////
custom_round_think()
{
	for( ;; )
	{
		level.round_spawn_func = maps\_zombiemode::round_spawning;
		maxreward = 50 * level.round_number;
		if ( maxreward > 500 )
			maxreward = 500;
		level.zombie_vars["rebuild_barrier_cap_per_round"] = maxreward;
		level.round_timer = level.zombie_vars["zombie_round_time"]; 
		add_later_round_spawners();
		maps\_zombiemode::chalk_one_up();
		maps\_zombiemode_powerups::powerup_round_start();
		players = get_players();
		array_thread( players, maps\_zombiemode_blockers::rebuild_barrier_reward_reset );
		level thread maps\_zombiemode::award_grenades_for_survivors();
		level.round_start_time = getTime();
		level thread [[level.round_spawn_func]]();
		level notify("start_of_round");
		maps\_zombiemode::round_wait(); 
		level.first_round = false;
		level notify("end_of_round");
		level thread maps\_zombiemode::spectators_respawn();
		level thread maps\_zombiemode::chalk_round_hint();
		wait( level.zombie_vars["zombie_between_round_time"] ); 
		timer = level.zombie_vars["zombie_spawn_delay"];
		if( timer < 0.08 )
		{
			timer = 0.08; 
		}	
		level.zombie_vars["zombie_spawn_delay"] = timer * 0.95;
		level.zombie_move_speed = level.round_number * 8;
		level.round_number++;
		level notify( "between_round_over" );
	}
}

/////////////////////
//  START MESSAGE  //
/////////////////////
start_message()
{
    i = 0;
    message_1 = create_simple_hud( self );
	message_1.alignX = "center"; 
	message_1.alignY = "top";
	message_1.horzAlign = "center"; 
	message_1.vertAlign = "top";
	message_1.x = 0; 
	message_1.y = 2; 
	message_1.fontscale = 1.7;
    message_1.alpha = i;
	message_1 setText("^5Patch By");

    message_2 = create_simple_hud( self );
	message_2.alignX = "center"; 
	message_2.alignY = "top";
	message_2.horzAlign = "center"; 
	message_2.vertAlign = "top";
	message_2.x = 0; 
	message_2.y = 20; 
	message_2.fontscale = 1.7;
    message_2.alpha = i;
	message_2 setText("^1Zombie AmazinG");

    wait 5;
    for(; i <= 1; i += 0.05 )
    {
        message_1.alpha = i;
        message_2.alpha = i;
        wait 0.05;
    }
    
    wait 5;
    for(; i >= 0; i -= 0.05 )
    {
        message_1.alpha = i;
        message_2.alpha = i;
        wait 0.05;
    }

	wait 10;
	message_1 destroy();
	message_2 destroy();
}

/////////////////////////////
//  TIMER AND ROUND TIMER  //
/////////////////////////////
lobby_timer()
{
	self.lobby_timer = create_simple_hud( self );
	self.lobby_timer.fontscale = 1.5;
	self.lobby_timer.alignX = "left"; 
	self.lobby_timer.alignY = "top";
	self.lobby_timer.horzAlign = "left"; 
	self.lobby_timer.vertAlign = "top";
	self.lobby_timer.x = 5;
	self.lobby_timer.y = 5;
	self.lobby_timer.alpha = 1;
	self.lobby_timer.label = "^6Total : ^5";
	flag_wait("all_players_spawned");
	self.lobby_timer setTimerUp(0);
}

round_timer()
{
	self.round_timer = create_simple_hud( self );
	self.round_timer.fontscale = 1.5;
	self.round_timer.alignX = "left"; 
	self.round_timer.alignY = "top";
	self.round_timer.horzAlign = "left"; 
	self.round_timer.vertAlign = "top";
	self.round_timer.x = 5;
	self.round_timer.y = 20;
	self.round_timer.alpha = 1;
	self.round_timer.label = "^6Round : ^5";
	self.round_timer setText("0:00");
}

reset_timer(){

    while(true)
    {
        wait 0.05;
        starttime = GetTime();
        while(!is_round_end()){
            wait 0.05;
        }
        
        endtime = GetTime();
        round_time = int((endtime - starttime)/1000);
       
        while(level.zombie_total<1)
        {
            wait 0.05;
            self.round_timer setTimer(round_time); 
        }

        self.round_timer setTimerUp(0);

    }
    

}

is_round_end()
{

    //if(GetAiArray("axis").size) return false;
    if( GetAiSpeciesArray( "axis", "all" ).size ) return false;

    if(level.zombie_total>0) return false;

    return true;
}

//////////////////////////
//  SECONDS PER HORDES  //
//////////////////////////
sph()
{
	if (level.script == "nazi_zombie_sumpf" || level.script == "nazi_zombie_factory")
	{
		self.sph = newclienthudelem(self);
		self.sph.fontscale = 1.5;
		self.sph.x = 5;
		self.sph.y = 50;
		self.sph.alpha = 1;
		self.sph.alignx = "left";
		self.sph.aligny = "top";
		self.sph.horzalign = "left";
		self.sph.vertalign = "top";
		self.sph.label = "^6SPH : ^5";
		self.sph setvalue(0);

		level waittill("start_of_round");
		self.sph.time_start = gettime() / 1000;
		self.sph.zombies_total_start = level.zombie_total + get_enemy_count();
		self.sph.kills = 0;

    	self thread updateSPH();

		while (true) 
		{
			level waittill("start_of_round");
			self.sph.time_start = gettime() / 1000;
    		self.sph.zombies_total_start = level.zombie_total + get_enemy_count();
		}
	}
}

updateSPH() {
    while (true) 
	{
        wait 1;
        time = gettime() / 1000;
        self.sph.time_elapsed = int(time - self.sph.time_start);
		self.sph.kills = self.sph.zombies_total_start - (get_enemy_count() + level.zombie_total);
        self.sph.hordas_fraction = self.sph.kills / 24.0;
        if (self.sph.hordas_fraction > 0)
            self.sph.sph_value = self.sph.time_elapsed / self.sph.hordas_fraction;
        else
            self.sph.sph_value = 0;
        self.sph setvalue((int(self.sph.sph_value * 100) / 100.0));
    }
}

///////////////////
//  DOG TRACKER  //
///////////////////

dog_tracker()
{
	if (level.script == "nazi_zombie_factory")
	{
		self.next_dog = newclienthudelem(self);
		self.next_dog.fontscale = 1.5;
		self.next_dog.x = 5;
		self.next_dog.y = 65;
		self.next_dog.alignx = "left";
		self.next_dog.aligny = "top";
		self.next_dog.horzalign = "left";
		self.next_dog.vertalign = "top";
		self.next_dog.label = "^6Next Dog : ^5";

		while(true)
		{
			wait 0.1;
			if(isDefined(level.next_dog_round))
			{
				self.next_dog setvalue(level.next_dog_round);
			}
		}
	}
}

//////////////
//  HEALTH  //
//////////////
health()
{
	self.vida_restante = create_simple_hud( self );
	self.vida_restante.alignX = "left"; 
	self.vida_restante.alignY = "top";
	self.vida_restante.horzAlign = "left"; 
	self.vida_restante.vertAlign = "top";
	self.vida_restante.x = 5; 
	self.vida_restante.y = 365; 
	self.vida_restante.fontscale = 1.5;
    self.vida_restante.alpha = 1;
	self.vida_restante.label = "^6Health : ^5";
	while(true)
	{
		self.vida_restante setvalue(self.health);
		wait 0.1;
	}
}

//////////////////////
//  ZOMBIE COUNTER  //
//////////////////////
zombie_counter()
{
    self.zombiecounter = newclienthudelem(self);
    self.zombiecounter.alignX = "center"; 
	self.zombiecounter.alignY = "bottom";
	self.zombiecounter.horzAlign = "center"; 
	self.zombiecounter.vertAlign = "bottom";
	self.zombiecounter.x = 0; 
	self.zombiecounter.y = -20; 
	self.zombiecounter.fontscale = 1.5;
	self.zombiecounter.alpha = 1;
	self.zombiecounter.label = "^6Zombies : ^5";

    for(;;){
		
        self.zombiecounter setvalue(level.zombie_total + get_enemy_count());
        wait 0.05;
    }
}

//////////////////////
//  BOX HIT TRACKER //
//////////////////////
score_box()
{
	level.box_hit_counter = 0;
    while(true)
    {
        player_points = self.score;
        wait 0.1;

        if(player_points == (self.score + 950))
        {
            level.box_hit_counter += 1;
        }
    }
}

box_hits()
{
	self.box_hits = newclienthudelem( self );
    self.box_hits.alignx = "left";
    self.box_hits.aligny = "top";
    self.box_hits.horzalign = "left";
    self.box_hits.vertalign = "top";
	self.box_hits.x = 5;
    self.box_hits.y = 35;
    self.box_hits.fontscale = 1.5;
    self.box_hits.alpha = 1;
	self.box_hits.label = "^6Box Hits : ^5";

	while(true)
	{
		wait 0.1;
		self.box_hits setvalue(level.box_hit_counter);
		
	}
}

//////////////////
//  TRAP TIMER  //
//////////////////
trap_timer_check()
{
    self.activate_timer = undefined;
    while(true)
    {
        player_points = self.score;
        wait 0.1;

		if (level.script == "nazi_zombie_asylum") //ver
		{
			if(player_points == (self.score + 1000) && level.round_number > 14) //use essa função em mapas que a trap custa 1000 pontos
        	{
            self.activate_timer = true;
            wait 50;    // You dont really need this, it prevents showing two timers when two traps are active
        	}
		}

		if (level.script == "nazi_zombie_factory") //der
		{
			if(player_points == (self.score + 1000) && level.round_number > 14) //use essa função em mapas que a trap custa 1000 pontos
        	{
            self.activate_timer = true;
            wait 50;    // You dont really need this, it prevents showing two timers when two traps are active
        	}
		}

		if (level.script == "nazi_zombie_sumpf") //snn
		{
			if(player_points == (self.score + 1000) && level.round_number > 14) //use essa função em mapas que a trap custa 1000 pontos
        	{
            self.activate_timer = true;
            wait 115;    // You dont really need this, it prevents showing two timers when two traps are active
        	}
		}
		

        self.activate_timer = false;
    }
}

zipline_check()
{
	self.activate_zipline = undefined;
    while(true)
    {
        player_points = self.score;
        wait 0.1;

		if (level.script == "nazi_zombie_sumpf") //snn
		{
			if(player_points == (self.score + 1500) && level.round_number > 14) //use essa função em mapas que a trap custa 1000 pontos
        	{
            self.activate_zipline = true;
            wait 46;    // You dont really need this, it prevents showing two timers when two traps are active
        	}
		}

        self.activate_zipline = false;
    }
}

flogger_check()
{
	self.activate_flogger = undefined;
    while(true)
    {
        player_points = self.score;
        wait 0.1;
		
		if (level.script == "nazi_zombie_sumpf") //snn
		{
			if(player_points == (self.score + 750) && level.round_number > 14) //use essa função em mapas que a trap custa 1000 pontos
        	{
            self.activate_flogger = true;
            wait 76;    // You dont really need this, it prevents showing two timers when two traps are active
        	}
		}

        self.activate_flogger = false;
    }
}

trap_timer()
{
	if (level.script == "nazi_zombie_prototype")
	{

	}
	else
	{
		self.trap_timer = newclienthudelem( self );
    	self.trap_timer.alignx = "left";
    	self.trap_timer.aligny = "top";
    	self.trap_timer.horzalign = "left";
    	self.trap_timer.vertalign = "top";
		if (level.script == "nazi_zombie_sumpf") //snn
		{
			self.trap_timer.x = 5;
    		self.trap_timer.y = 65;
		}
		else
		{
			self.trap_timer.x = 5;
    		self.trap_timer.y = 80;
		}

		if (level.script == "nazi_zombie_asylum") //ver
		{
			self.trap_timer.x = 5;
    		self.trap_timer.y = 50;
		}
		else
		{
			self.trap_timer.x = 5;
    		self.trap_timer.y = 80;
		}
    	self.trap_timer.fontscale = 1.5;
    	self.trap_timer.alpha = 1;

    	while( 1 )
    	{
			while(!self.activate_timer) //use essa função em mapas que a trap dura 25 segundos e carrega em 25 segundos
    	        wait 0.1;
    	    {
				if (level.script == "nazi_zombie_asylum") //ver
				{
					wait 0.1;
					self.trap_timer.label = "^6Trap : ^2";
    	        	self.trap_timer.alpha = 1;
    	        	self.trap_timer settimer( 25 );
    	        	wait 25;
    	        	self.trap_timer settimer( 25 );
    	        	self.trap_timer.label = "^6Trap : ^1";
    	        	wait 25;
    	        	self.trap_timer.alpha = 0;
				}
				if (level.script == "nazi_zombie_factory") //der
				{
					wait 0.1;
    	        	self.trap_timer.label = "^6Trap : ^2";
    	        	self.trap_timer.alpha = 1;
    	        	self.trap_timer settimer( 25 );
    	        	wait 25;
    	        	self.trap_timer settimer( 25 );
    	        	self.trap_timer.label = "^6Trap : ^1";
    	        	wait 25;
    	        	self.trap_timer.alpha = 0;
				}
				if (level.script == "nazi_zombie_sumpf") //snn
				{
					wait 0.1;
    	        	self.trap_timer.label = "^6Trap : ^2";
    	        	self.trap_timer.alpha = 1;
    	        	self.trap_timer settimer( 25 );
    	        	wait 25;
    	        	self.trap_timer settimer( 90 );
    	        	self.trap_timer.label = "^6Trap : ^1";
    	        	wait 90;
    	        	self.trap_timer.alpha = 0;
				}
    	    }
    	    wait 0.1;
    	}
	}
    
}

zipline_timer()
{
	if (level.script == "nazi_zombie_sumpf") //snn
	{
    	self.trap_zipline = newclienthudelem( self );
    	self.trap_zipline.alignx = "left";
    	self.trap_zipline.aligny = "top";
    	self.trap_zipline.horzalign = "left";
    	self.trap_zipline.vertalign = "top";
		self.trap_zipline.x = 5;
    	self.trap_zipline.y = 95;
    	self.trap_zipline.fontscale = 1.5;
    	self.trap_zipline.alpha = 1;

    	while( 1 )
    	{
			while(!self.activate_zipline) //use essa função em mapas que a trap dura 25 segundos e carrega em 25 segundos
    	    wait 0.1;
    	    {
				wait 0.1;
				self.trap_zipline_text.alpha = 1;
    	        self.trap_zipline.label = "^6Zipline : ^2";
    	        self.trap_zipline.alpha = 1;
    	        self.trap_zipline settimer( 6 );
    	        wait 6;
    	        self.trap_zipline settimer( 40 );
    	        self.trap_zipline.label = "^6Zipline : ^1";
    	        wait 40;
    	        self.trap_zipline.alpha = 0;
    	    }
    	    wait 0.1;
    	}
	}
}

flogger_timer()
{
	if (level.script == "nazi_zombie_sumpf") //snn
	{
		self.trap_flogger = newclienthudelem( self );
    	self.trap_flogger.alignx = "left";
    	self.trap_flogger.aligny = "top";
    	self.trap_flogger.horzalign = "left";
    	self.trap_flogger.vertalign = "top";
		self.trap_flogger.x = 5;
    	self.trap_flogger.y = 65;
    	self.trap_flogger.fontscale = 1.5;
    	self.trap_flogger.alpha = 1;

    	while( 1 )
    	{
			while(!self.activate_flogger) //use essa função em mapas que a trap dura 25 segundos e carrega em 25 segundos
    	        wait 0.1;
    	    {
				wait 0.1;
    	        self.trap_flogger.label = "^6Flogger : ^2";
    	        self.trap_flogger.alpha = 1;
    	        self.trap_flogger settimer( 31 );
    	        wait 31;
    	        self.trap_flogger settimer( 45 );
    	        self.trap_flogger.label = "^6Flogger : ^1";
    	        wait 45;
    	        self.trap_flogger.alpha = 0;
    	    }
    	    wait 0.1;
    	}
	}
}