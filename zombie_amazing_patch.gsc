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

	level.timer_hud = 0;
	level.round_timer_hud = 0;
	level.box_hit_hud = 0;
	level.sph_hud = 0;
	level.next_dog_hud = 0;
	level.health_hud = 0;
	level.zombie_counter_hud = 0;
	level.trap_timer_hud = 0;
	level.timestamps[0] = 0;
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
			self thread readchat();
			self thread lobby_timer();
			self thread round_timer();
			self thread reset_timer();
			self thread sph();
			self thread sph_hud();
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

////////////////////
//  READ MESSAGE  //
////////////////////
readchat() 
{
    self endon("end_game");
    while (true) 
    {
        level waittill("say", message, player);
        msg = strtok(message, " ");

        if(msg[0][0] != "!")
            continue;

        switch(msg[0])
        {
            case "!lobby": level.timer_hud = !level.timer_hud; break; 
			case "!round": level.round_timer_hud = !level.round_timer_hud; break; 
			case "!box": level.box_hit_hud = !level.box_hit_hud; break; 
			case "!sph": level.sph_hud = !level.sph_hud; break; 
			case "!dog": level.next_dog_hud = !level.next_dog_hud; break; 
			case "!health": level.health_hud = !level.health_hud; break;
			case "!zombie": level.zombie_counter_hud = !level.zombie_counter_hud; break;
			case "!trap": level.trap_timer_hud = !level.trap_timer_hud; break;
			case "!times": show_all_timestamps(); break;
        }
    }
}

/////////////////////////////
//  TIMER AND ROUND TIMER  //
/////////////////////////////
lobby_timer()
{
	level.FRFIX_START = int(getTime() / 1000);
	self.lobby_timer = create_simple_hud( self );
	self.lobby_timer.fontscale = 1.5;
	self.lobby_timer.alignX = "left"; 
	self.lobby_timer.alignY = "top";
	self.lobby_timer.horzAlign = "left"; 
	self.lobby_timer.vertAlign = "top";
	self.lobby_timer.x = 5;
	self.lobby_timer.y = 5;
	self.lobby_timer.label = "^6Total : ^5";
	flag_wait("all_players_spawned");
	self.lobby_timer setTimerUp(0);
	while(true)
	{
		wait 0.1;
		if (level.timer_hud)
		{
			self.lobby_timer.alpha = 1;
		}
		else
		{
			self.lobby_timer.alpha = 0;
		}
	}
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
	self.round_timer.label = "^6Round : ^5";
	self.round_timer setText("0:00");
	while(true)
	{
		wait 0.1;
		if (level.round_timer_hud)
		{
			if (level.timer_hud)
			{
				self.round_timer.y = 20;
			}
			else
			{
				self.round_timer.y = 5;
			}
			self.round_timer.alpha = 1;
		}
		else
		{
			self.round_timer.alpha = 0;
		}
	}
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
		level thread show_split();
    }
    

}

is_round_end()
{

    //if(GetAiArray("axis").size) return false;
    if( GetAiSpeciesArray( "axis", "all" ).size ) return false;

    if(level.zombie_total>0) return false;

    return true;
}

//////////////////
//  SHOW TIMES  //
//////////////////
show_all_timestamps()
{
	//reset layouts
	self.round_30 destroy();
	self.round_50 destroy();
	self.round_70 destroy();
	self.round_100 destroy();
	self.round_150 destroy();
	self.round_200 destroy();
	self.round_1000 destroy();
	self.round_2000 destroy();
	self.round_3000 destroy();
	self.round_4000 destroy();
	self.round_5000 destroy();
	self.round_6000 destroy();
	self.round_7000 destroy();
	self.round_8000 destroy();
	self.round_9000 destroy();
	self.round_10000 destroy();
	self.round_11000 destroy();

	if (level.round_number > 29)
	{
		self.round_30 = create_simple_hud( self );
		self.round_30.alignX = "right"; 
		self.round_30.alignY = "bottom";
		self.round_30.horzAlign = "right"; 
		self.round_30.vertAlign = "bottom";
		self.round_30.x = -5; 
		self.round_30.y = -85; 
		self.round_30.fontscale = 1.2;
		self.round_30.label = "^1Round 30 : ^7";
		self.round_30.alpha = 1;
		self.round_30 setText(level.timestamps[1]);
	}

	if (level.round_number > 49)
	{
		self.round_50 = create_simple_hud( self );
		self.round_50.alignX = "right"; 
		self.round_50.alignY = "bottom";
		self.round_50.horzAlign = "right"; 
		self.round_50.vertAlign = "bottom";
		self.round_50.x = -5; 
		self.round_50.y = -95; 
		self.round_50.fontscale = 1.2;
		self.round_50.label = "^1Round 50 : ^7";
		self.round_50.alpha = 1;
		self.round_50 setText(level.timestamps[2]);
	}

	if (level.round_number > 69)
	{
		self.round_70 = create_simple_hud( self );
		self.round_70.alignX = "right"; 
		self.round_70.alignY = "bottom";
		self.round_70.horzAlign = "right"; 
		self.round_70.vertAlign = "bottom";
		self.round_70.x = -5; 
		self.round_70.y = -105; 
		self.round_70.fontscale = 1.2;
		self.round_70.label = "^1Round 70 : ^7";
		self.round_70.alpha = 1;
		self.round_70 setText(level.timestamps[3]);
	}

	if (level.round_number > 99)
	{
		self.round_100 = create_simple_hud( self );
		self.round_100.alignX = "right"; 
		self.round_100.alignY = "bottom";
		self.round_100.horzAlign = "right"; 
		self.round_100.vertAlign = "bottom";
		self.round_100.x = -5; 
		self.round_100.y = -115; 
		self.round_100.fontscale = 1.2;
		self.round_100.label = "^1Round 100 : ^7";
		self.round_100.alpha = 1;
		self.round_100 setText(level.timestamps[4]);
	}

	if (level.round_number > 149)
	{
		self.round_150 = create_simple_hud( self );
		self.round_150.alignX = "right"; 
		self.round_150.alignY = "bottom";
		self.round_150.horzAlign = "right"; 
		self.round_150.vertAlign = "bottom";
		self.round_150.x = -5; 
		self.round_150.y = -125; 
		self.round_150.fontscale = 1.2;
		self.round_150.label = "^1Round 150 : ^7";
		self.round_150.alpha = 1;
		self.round_150 setText(level.timestamps[5]);
	}

	if (level.round_number > 199)
	{
		self.round_200 = create_simple_hud( self );
		self.round_200.alignX = "right"; 
		self.round_200.alignY = "bottom";
		self.round_200.horzAlign = "right"; 
		self.round_200.vertAlign = "bottom";
		self.round_200.x = -5; 
		self.round_200.y = -135; 
		self.round_200.fontscale = 1.2;
		self.round_200.label = "^1Round 200 : ^7";
		self.round_200.alpha = 1;
		self.round_200 setText(level.timestamps[6]);
	}

	if (level.round_number > 999)
	{
		self.round_1000 = create_simple_hud( self );
		self.round_1000.alignX = "right"; 
		self.round_1000.alignY = "bottom";
		self.round_1000.horzAlign = "right"; 
		self.round_1000.vertAlign = "bottom";
		self.round_1000.x = -5; 
		self.round_1000.y = -145; 
		self.round_1000.fontscale = 1.2;
		self.round_1000.label = "^1Round 1000 : ^7";
		self.round_1000.alpha = 1;
		self.round_1000 setText(level.timestamps[7]);
	}

	if (level.round_number > 1999)
	{
		self.round_2000 = create_simple_hud( self );
		self.round_2000.alignX = "right"; 
		self.round_2000.alignY = "bottom";
		self.round_2000.horzAlign = "right"; 
		self.round_2000.vertAlign = "bottom";
		self.round_2000.x = -5; 
		self.round_2000.y = -155; 
		self.round_2000.fontscale = 1.2;
		self.round_2000.label = "^1Round 2000 : ^7";
		self.round_2000.alpha = 1;
		self.round_2000 setText(level.timestamps[8]);
	}

	if (level.round_number > 2999)
	{
		self.round_3000 = create_simple_hud( self );
		self.round_3000.alignX = "right"; 
		self.round_3000.alignY = "bottom";
		self.round_3000.horzAlign = "right"; 
		self.round_3000.vertAlign = "bottom";
		self.round_3000.x = -5; 
		self.round_3000.y = -165; 
		self.round_3000.fontscale = 1.2;
		self.round_3000.label = "^1Round 3000 : ^7";
		self.round_3000.alpha = 1;
		self.round_3000 setText(level.timestamps[9]);
	}

	if (level.round_number > 3999)
	{
		self.round_4000 = create_simple_hud( self );
		self.round_4000.alignX = "right"; 
		self.round_4000.alignY = "bottom";
		self.round_4000.horzAlign = "right"; 
		self.round_4000.vertAlign = "bottom";
		self.round_4000.x = -5; 
		self.round_4000.y = -175; 
		self.round_4000.fontscale = 1.2;
		self.round_4000.label = "^1Round 4000 : ^7";
		self.round_4000.alpha = 1;
		self.round_4000 setText(level.timestamps[10]);
	}

	if (level.round_number > 4999)
	{
		self.round_5000 = create_simple_hud( self );
		self.round_5000.alignX = "right"; 
		self.round_5000.alignY = "bottom";
		self.round_5000.horzAlign = "right"; 
		self.round_5000.vertAlign = "bottom";
		self.round_5000.x = -5; 
		self.round_5000.y = -185; 
		self.round_5000.fontscale = 1.2;
		self.round_5000.label = "^1Round 5000 : ^7";
		self.round_5000.alpha = 1;
		self.round_5000 setText(level.timestamps[11]);
	}

	if (level.round_number > 5999)
	{
		self.round_6000 = create_simple_hud( self );
		self.round_6000.alignX = "right"; 
		self.round_6000.alignY = "bottom";
		self.round_6000.horzAlign = "right"; 
		self.round_6000.vertAlign = "bottom";
		self.round_6000.x = -5; 
		self.round_6000.y = -195; 
		self.round_6000.fontscale = 1.2;
		self.round_6000.label = "^1Round 6000 : ^7";
		self.round_6000.alpha = 1;
		self.round_6000 setText(level.timestamps[12]);
	}

	if (level.round_number > 6999)
	{
		self.round_7000 = create_simple_hud( self );
		self.round_7000.alignX = "right"; 
		self.round_7000.alignY = "bottom";
		self.round_7000.horzAlign = "right"; 
		self.round_7000.vertAlign = "bottom";
		self.round_7000.x = -5; 
		self.round_7000.y = -205; 
		self.round_7000.fontscale = 1.2;
		self.round_7000.label = "^1Round 7000 : ^7";
		self.round_7000.alpha = 1;
		self.round_7000 setText(level.timestamps[13]);
	}

	if (level.round_number > 7999)
	{
		self.round_8000 = create_simple_hud( self );
		self.round_8000 = create_simple_hud( self );
		self.round_8000.alignX = "right"; 
		self.round_8000.alignX = "right"; 
		self.round_8000.alignY = "bottom";
		self.round_8000.horzAlign = "right"; 
		self.round_8000.vertAlign = "bottom";
		self.round_8000.x = -5; 
		self.round_8000.y = -215; 
		self.round_8000.fontscale = 1.2;
		self.round_8000.label = "^1Round 8000 : ^7";
		self.round_8000.alpha = 1;
		self.round_8000 setText(level.timestamps[14]);
	}

	if (level.round_number > 8999)
	{
		self.round_9000 = create_simple_hud( self );
		self.round_9000.alignX = "right"; 
		self.round_9000.alignY = "bottom";
		self.round_9000.horzAlign = "right"; 
		self.round_9000.vertAlign = "bottom";
		self.round_9000.x = -5; 
		self.round_9000.y = -225; 
		self.round_9000.fontscale = 1.2;
		self.round_9000.label = "^1Round 9000 : ^7";
		self.round_9000.alpha = 1;
		self.round_9000 setText(level.timestamps[15]);
	}

	if (level.round_number > 9999)
	{
		self.round_10000 = create_simple_hud( self );
		self.round_10000.alignX = "right"; 
		self.round_10000.alignY = "bottom";
		self.round_10000.horzAlign = "right"; 
		self.round_10000.vertAlign = "bottom";
		self.round_10000.x = -5; 
		self.round_10000.y = -235; 
		self.round_10000.fontscale = 1.2;
		self.round_10000.label = "^1Round 10000 : ^7";
		self.round_10000.alpha = 1;
		self.round_10000 setText(level.timestamps[16]);
	}

	if (level.round_number > 10999)
	{
		self.round_11000 = create_simple_hud( self );
		self.round_11000.alignX = "right"; 
		self.round_11000.alignY = "bottom";
		self.round_11000.horzAlign = "right"; 
		self.round_11000.vertAlign = "bottom";
		self.round_11000.x = -5; 
		self.round_11000.y = -245; 
		self.round_11000.fontscale = 1.2;
		self.round_11000.label = "^1Round 11000 : ^7";
		self.round_11000.alpha = 1;
		self.round_11000 setText(level.timestamps[17]);
	}

	wait 10;
	self.round_30 destroy();
	self.round_50 destroy();
	self.round_70 destroy();
	self.round_100 destroy();
	self.round_150 destroy();
	self.round_200 destroy();
	self.round_1000 destroy();
	self.round_2000 destroy();
	self.round_3000 destroy();
	self.round_4000 destroy();
	self.round_5000 destroy();
	self.round_6000 destroy();
	self.round_7000 destroy();
	self.round_8000 destroy();
	self.round_9000 destroy();
	self.round_10000 destroy();
	self.round_11000 destroy();
}

show_split()
{
	level endon("end_game");

    switch (level.round_number)
    {
		case 30:
        case 50:
        case 70:
        case 100:
        case 150:
        case 200:
		case 1000:
		case 2000:
		case 3000:
		case 4000:
		case 5000:
		case 6000:
		case 7000:
		case 8000:
		case 9000:
		case 10000:
		case 11000:
            break;
        default:
            return;
    }

    timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
	level.timestamps[level.timestamps.size] = timestamp;
	iPrintLnBold("Round " + (level.round_number) + ": ^1" + timestamp);
}

convert_time(seconds)
{
	hours = 0;
	minutes = 0;
	
	if (seconds > 59)
	{
		minutes = int(seconds / 60);

		seconds = int(seconds * 1000) % (60 * 1000);
		seconds = seconds * 0.001;

		if (minutes > 59)
		{
			hours = int(minutes / 60);
			minutes = int(minutes * 1000) % (60 * 1000);
			minutes = minutes * 0.001;
		}
	}

	str_hours = hours;
	if (hours < 10)
		str_hours = "0" + hours;

	str_minutes = minutes;
	if (minutes < 10 && hours > 0)
		str_minutes = "0" + minutes;

	str_seconds = seconds;
	if (seconds < 10)
		str_seconds = "0" + seconds;

	if (hours == 0)
		combined = "" + str_minutes  + ":" + str_seconds;
	else
		combined = "" + str_hours  + ":" + str_minutes  + ":" + str_seconds;

	return combined;
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

sph_hud()
{
	while(true)
	{
		wait 0.1;
		if (level.sph_hud)
		{
			if (level.box_hit_hud)
			{
				if (level.round_timer_hud)
				{
					if (level.timer_hud)
					{
						self.sph.y = 50;
					}
					else
					{
						self.sph.y = 35;
					}
				}
				else
				{
					if (level.timer_hud)
					{
						self.sph.y = 35;
					}
					else
					{
						self.sph.y = 20;
					}
				}
			}
			else
			{
				if (level.round_timer_hud)
				{
					if (level.timer_hud)
					{
						self.sph.y = 35;
					}
					else
					{
						self.sph.y = 20;
					}
				}
				else
				{
					if (level.timer_hud)
					{
						self.sph.y = 20;
					}
					else
					{
						self.sph.y = 5;
					}
				}
			}
			self.sph.alpha = 1;
		}
		else
		{
			self.sph.alpha = 0;
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
		self.next_dog.alignx = "left";
		self.next_dog.aligny = "top";
		self.next_dog.horzalign = "left";
		self.next_dog.vertalign = "top";
		self.next_dog.label = "^6Next Dog : ^5";

		while(true)
		{
			wait 0.1;
			if (level.next_dog_hud)
			{
				if(level.sph_hud)
				{
					if (level.box_hit_hud)
					{
						if (level.round_timer_hud)
						{
							if (level.timer_hud)
							{
								self.next_dog.y = 65;
							}
							else
							{
								self.next_dog.y = 50;
							}
						}
						else
						{
							if (level.timer_hud)
							{
								self.next_dog.y = 50;
							}
							else
							{
								self.next_dog.y = 35;
							}
						}
					}
					else
					{
						if (level.round_timer_hud)
						{
							if (level.timer_hud)
							{
								self.next_dog.y = 50;
							}
							else
							{
								self.next_dog.y = 35;
							}
						}
						else
						{
							if (level.timer_hud)
							{
								self.next_dog.y = 35;
							}
							else
							{
								self.next_dog.y = 20;
							}
						}
					}
				}
				else
				{
					if (level.box_hit_hud)
					{
						if (level.round_timer_hud)
						{
							if (level.timer_hud)
							{
								self.next_dog.y = 50;
							}
							else
							{
								self.next_dog.y = 35;
							}
						}
						else
						{
							if (level.timer_hud)
							{
								self.next_dog.y = 35;
							}
							else
							{
								self.next_dog.y = 20;
							}
						}
					}
					else
					{
						if (level.round_timer_hud)
						{
							if (level.timer_hud)
							{
								self.next_dog.y = 35;
							}
							else
							{
								self.next_dog.y = 20;
							}
						}
						else
						{
							if (level.timer_hud)
							{
								self.next_dog.y = 20;
							}
							else
							{
								self.next_dog.y = 5;
							}
						}
					}
				}
				self.next_dog.alpha = 1;
			}
			else
			{
				self.next_dog.alpha = 0;
			}
			self.next_dog setvalue(level.next_dog_round);
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
	self.vida_restante.label = "^6Health : ^5";
	while(true)
	{
		wait 0.1;
		if (level.health_hud)
		{
			self.vida_restante.alpha = 1;
			self.vida_restante setvalue(self.health);
		}
		else
		{
			self.vida_restante.alpha = 0;
		}
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
	self.zombiecounter.label = "^6Zombies : ^5";

    for(;;)
	{
		wait 0.05;
		if (level.zombie_counter_hud)
		{
			self.zombiecounter.alpha = 1;
			self.zombiecounter setvalue(level.zombie_total + get_enemy_count());
		}
		else
		{
			self.zombiecounter.alpha = 0;
		}
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
    self.box_hits.fontscale = 1.5;
	self.box_hits.label = "^6Box Hits : ^5";

	while(true)
	{
		wait 0.1;
		if (level.box_hit_hud)
		{
			if (level.round_timer_hud)
			{
				if (level.timer_hud)
				{
					self.box_hits.y = 35;
				}
				else
				{
					self.box_hits.y = 20;
				}
			}
			else
			{
				if (level.timer_hud)
				{
					self.box_hits.y = 20;
				}
				else
				{
					self.box_hits.y = 5;
				}
			}
			self.box_hits.alpha = 1;
		}
		else
		{
			self.box_hits.alpha = 0;
		}
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

		if (level.trap_timer_hud)
		{
			if (level.script == "nazi_zombie_asylum") //ver
			{
				if(player_points == (self.score + 1000) && level.round_number > 1) //use essa função em mapas que a trap custa 1000 pontos
        		{
        	    self.activate_timer = true;
        	    wait 50;    // You dont really need this, it prevents showing two timers when two traps are active
        		}
			}

			if (level.script == "nazi_zombie_factory") //der
			{
				if(player_points == (self.score + 1000) && level.round_number > 1) //use essa função em mapas que a trap custa 1000 pontos
        		{
        	    self.activate_timer = true;
        	    wait 50;    // You dont really need this, it prevents showing two timers when two traps are active
        		}
			}

			if (level.script == "nazi_zombie_sumpf") //snn
			{
				if(player_points == (self.score + 1000) && level.round_number > 1) //use essa função em mapas que a trap custa 1000 pontos
        		{
        	    self.activate_timer = true;
        	    wait 115;    // You dont really need this, it prevents showing two timers when two traps are active
        		}
			}
			self.activate_timer = false;
		}
		else
		{
			self.trap_timer.alpha = 0;
			self.trap_zipline.alpha = 0;
			self.trap_flogger.alpha = 0;
		}
    }
}

zipline_check()
{
	self.activate_zipline = undefined;
    while(true)
    {
        player_points = self.score;
		wait 0.1;

		if (level.trap_timer_hud)
		{
			if (level.script == "nazi_zombie_sumpf") //snn
			{
				if(player_points == (self.score + 1500) && level.round_number > 1) //use essa função em mapas que a trap custa 1000 pontos
        		{
        	    self.activate_zipline = true;
        	    wait 46;    // You dont really need this, it prevents showing two timers when two traps are active
        		}
			}
			self.activate_zipline = false;
		}
		else
		{
			self.trap_timer.alpha = 0;
			self.trap_zipline.alpha = 0;
			self.trap_flogger.alpha = 0;
		}
    }
}

flogger_check()
{
	self.activate_flogger = undefined;
    while(true)
    {
        player_points = self.score;
		wait 0.1;
		
		if (level.trap_timer_hud)
		{
			if (level.script == "nazi_zombie_sumpf") //snn
			{
				if(player_points == (self.score + 750) && level.round_number > 1) //use essa função em mapas que a trap custa 1000 pontos
        		{
        	    self.activate_flogger = true;
        	    wait 76;    // You dont really need this, it prevents showing two timers when two traps are active
        		}
			}

        	self.activate_flogger = false;
		}
		else
		{
			self.trap_timer.alpha = 0;
			self.trap_zipline.alpha = 0;
			self.trap_flogger.alpha = 0;
		}
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
    	self.trap_timer.alignx = "center";
    	self.trap_timer.aligny = "top";
    	self.trap_timer.horzalign = "center";
    	self.trap_timer.vertalign = "top";
    	self.trap_timer.fontscale = 1.5;
		self.trap_timer.x = 0;
		//self.trap_timer.y = 5;
    	self.trap_timer.alpha = 1;

    	while( 1 )
    	{
			while(!self.activate_timer) //use essa função em mapas que a trap dura 25 segundos e carrega em 25 segundos
    	        wait 0.1;
    	    {
				if (level.script == "nazi_zombie_asylum") //ver
				{
					wait 0.1;
					self.trap_timer.y = 5;
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
					self.trap_timer.y = 5;
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
					if (self.activate_flogger)
					{
						if (self.activate_zipline)
						{
							self.trap_timer.y = 35;
						}
						else
						{
							self.trap_timer.y = 20;
						}
					}
					else if (self.activate_zipline)
					{
						if (self.activate_flogger)
						{
							self.trap_timer.y = 35;
						}
						else
						{
							self.trap_timer.y = 20;
						}
					}
					else
					{
						self.trap_timer.y = 5;
					}
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
    	self.trap_zipline.alignx = "center";
    	self.trap_zipline.aligny = "top";
    	self.trap_zipline.horzalign = "center";
    	self.trap_zipline.vertalign = "top";
		self.trap_zipline.x = 0;
		//self.trap_zipline.y = 35;
    	self.trap_zipline.fontscale = 1.5;
    	self.trap_zipline.alpha = 1;

    	while( 1 )
    	{
			while(!self.activate_zipline) //use essa função em mapas que a trap dura 25 segundos e carrega em 25 segundos
    	    wait 0.1;
    	    {
				wait 0.1;
				if (self.activate_timer)
				{
					if (self.activate_flogger)
					{
						self.trap_zipline.y = 35;
					}
					else
					{
						self.trap_zipline.y = 20;
					}
				}
				else if (self.activate_flogger)
				{
					if (self.activate_timer)
					{
						self.trap_zipline.y = 35;
					}
					else
					{
						self.trap_zipline.y = 20;
					}
				}
				else
				{
					self.trap_zipline.y = 5;
				}
				self.trap_zipline.alpha = 1;
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
    	self.trap_flogger.alignx = "center";
    	self.trap_flogger.aligny = "top";
    	self.trap_flogger.horzalign = "center";
    	self.trap_flogger.vertalign = "top";
		self.trap_flogger.x = 0;
		//self.trap_flogger.y = 20;
    	self.trap_flogger.fontscale = 1.5;
    	self.trap_flogger.alpha = 1;

    	while( 1 )
    	{
			while(!self.activate_flogger) //use essa função em mapas que a trap dura 25 segundos e carrega em 25 segundos
    	        wait 0.1;
    	    {
				wait 0.1;
				if (self.activate_timer)
				{
					if (self.activate_zipline)
					{
						self.trap_flogger.y = 35;
					}
					else
					{
						self.trap_flogger.y = 20;
					}
				}
				else if (self.activate_zipline)
				{
					if (self.activate_timer)
					{
						self.trap_flogger.y = 35;
					}
					else
					{
						self.trap_flogger.y = 20;
					}
				}
				else
				{
					self.trap_flogger.y = 5;
				}
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