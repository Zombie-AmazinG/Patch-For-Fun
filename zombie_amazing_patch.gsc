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

	//comandos

	if ( GetDvar ( "lobby_timer" ) == "")
		setDvar ( "lobby_timer", 1 );
	if ( GetDvarInt ( "lobby_timer" ) > 1)
		setDvar ( "lobby_timer", 1 );

	if ( GetDvar ( "round_timer" ) == "")
		setDvar ( "round_timer", 1 );
	if ( GetDvarInt ( "round_timer" ) > 1)
		setDvar ( "round_timer", 1 );

	if ( GetDvar ( "sph" ) == "")
		setDvar ( "sph", 0 );
	if ( GetDvarInt ( "sph" ) > 1)
		setDvar ( "sph", 1 );

	if ( GetDvar ( "zombie_counter" ) == "")
		setDvar ( "zombie_counter", 0 );
	if ( GetDvarInt ( "zombie_counter" ) > 1)
		setDvar ( "zombie_counter", 1 );

	if ( GetDvar ( "hp" ) == "")
		setDvar ( "hp", 0 );
	if ( GetDvarInt ( "hp" ) > 1)
		setDvar ( "hp", 1 );

	if ( GetDvar ( "trap_timer" ) == "")
		setDvar ( "trap_timer", 0 );
	if ( GetDvarInt ( "trap_timer" ) > 1)
		setDvar ( "trap_timer", 1 );

	if ( GetDvar ( "box_hits" ) == "")
		setDvar ( "box_hits", 0 );
	if ( GetDvarInt ( "box_hits" ) > 1)
		setDvar ( "box_hits", 1 );

	if ( GetDvar ( "next_dog" ) == "")
		setDvar ( "next_dog", 0 );
	if ( GetDvarInt ( "next_dog" ) > 1)
		setDvar ( "next_dog", 1 );

	level.round_30_timer = 0;
	level.round_50_timer = 0;
	level.round_70_timer = 0;
	level.round_100_timer = 0;
	level.round_150_timer = 0;
	level.round_200_timer = 0;
	level.round_1000_timer = 0;
	level.round_2000_timer = 0;
	level.round_3000_timer = 0;
	level.round_4000_timer = 0;
	level.round_5000_timer = 0;
	level.round_6000_timer = 0;
	level.round_7000_timer = 0;
	level.round_8000_timer = 0;
	level.round_9000_timer = 0;
	level.round_10000_timer = 0;
	level.round_11000_timer = 0;
	level.round_12000_timer = 0;
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
	player = get_players();
    self endon("end_game");
    while (true) 
    {
        level waittill("say", message, player);
        msg = strtok(message, " ");

        if(msg[0][0] != "!")
            continue;

        switch(msg[0])
		{
			case "!time":
			switch(msg[1])
			{
				case "30": show_round_30(); break;
				case "50": show_round_50(); break;
				case "70": show_round_70(); break;
				case "100": show_round_100(); break;
				case "150": show_round_150(); break;
				case "200": show_round_200(); break;
				case "1000": show_round_1000(); break;
				case "2000": show_round_2000(); break;
				case "3000": show_round_3000(); break;
				case "4000": show_round_4000(); break;
				case "5000": show_round_5000(); break;
				case "6000": show_round_6000(); break;
				case "7000": show_round_7000(); break;
				case "8000": show_round_8000(); break;
				case "9000": show_round_9000(); break;
				case "10000": show_round_10000(); break;
				case "11000": show_round_11000(); break;
				case "12000": show_round_12000(); break;
				default: iprintlnbold("^1Invalid Command"); break;
			}
			break;
			default: iprintlnbold("^1Invalid Command"); break;
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
		if ( GetDvarInt ( "lobby_timer" ) == 1)
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
		if ( GetDvarInt ( "round_timer" ) == 1)
		{
			if ( GetDvarInt ( "lobby_timer" ) == 1)
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
    if( GetAiSpeciesArray( "axis", "all" ).size ) return false;

    if(level.zombie_total>0) return false;

    return true;
}

//////////////////
//  SHOW TIMES  //
//////////////////
show_round_30()
{
	if (level.round_number < 30)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 30 : ^1" + level.round_30_timer);
	}
}

show_round_50()
{
	if (level.round_number < 50)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 50 : ^1" + level.round_50_timer);
	}
}

show_round_70()
{
	if (level.round_number < 70)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 70 : ^1" + level.round_70_timer);
	}
}

show_round_100()
{
	if (level.round_number < 100)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 100 : ^1" + level.round_100_timer);
	}
}

show_round_150()
{
	if (level.round_number < 150)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 150 : ^1" + level.round_150_timer);
	}
}

show_round_200()
{
	if (level.round_number < 200)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 200 : ^1" + level.round_200_timer);
	}
}

show_round_1000()
{
	if (level.round_number < 1000)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 1000 : ^1" + level.round_1000_timer);
	}
}

show_round_2000()
{
	if (level.round_number < 2000)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 2000 : ^1" + level.round_2000_timer);
	}
}

show_round_3000()
{
	if (level.round_number < 3000)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 3000 : ^1" + level.round_3000_timer);
	}
}

show_round_4000()
{
	if (level.round_number < 4000)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 4000 : ^1" + level.round_4000_timer);
	}
}

show_round_5000()
{
	if (level.round_number < 5000)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 5000 : ^1" + level.round_5000_timer);
	}
}

show_round_6000()
{
	if (level.round_number < 6000)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 6000 : ^1" + level.round_6000_timer);
	}
}

show_round_7000()
{
	if (level.round_number < 7000)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 7000 : ^1" + level.round_7000_timer);
	}
}

show_round_8000()
{
	if (level.round_number < 8000)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 8000 : ^1" + level.round_8000_timer);
	}
}

show_round_9000()
{
	if (level.round_number < 9000)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 9000 : ^1" + level.round_9000_timer);
	}
}

show_round_10000()
{
	if (level.round_number < 10000)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 10000 : ^1" + level.round_10000_timer);
	}
}

show_round_11000()
{
	if (level.round_number < 11000)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 11000 : ^1" + level.round_11000_timer);
	}
}

show_round_12000()
{
	if (level.round_number < 12000)
	{
		iprintlnbold("No Time Available");
	}
	else
	{
		iprintlnbold("Round 12000 : ^1" + level.round_12000_timer);
	}
}

show_split()
{
	level endon("end_game");

	if (level.round_number == 30)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_30_timer = timestamp;
		iPrintLnBold("Round 30 : ^1" + timestamp);
	}
	else if (level.round_number == 50)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_50_timer = timestamp;
		iPrintLnBold("Round 50 : ^1" + timestamp);
	}
	else if (level.round_number == 70)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_70_timer = timestamp;
		iPrintLnBold("Round 70 : ^1" + timestamp);
	}
	else if (level.round_number == 100)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_100_timer = timestamp;
		iPrintLnBold("Round 100 : ^1" + timestamp);
	}
	else if (level.round_number == 150)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_150_timer = timestamp;
		iPrintLnBold("Round 150 : ^1" + timestamp);
	}
	else if (level.round_number == 200)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_200_timer = timestamp;
		iPrintLnBold("Round 200 : ^1" + timestamp);
	}
	else if (level.round_number == 1000)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_1000_timer = timestamp;
		iPrintLnBold("Round 1000 : ^1" + timestamp);
	}
	else if (level.round_number == 2000)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_2000_timer = timestamp;
		iPrintLnBold("Round 2000 : ^1" + timestamp);
	}
	else if (level.round_number == 3000)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_3000_timer = timestamp;
		iPrintLnBold("Round 3000 : ^1" + timestamp);
	}
	else if (level.round_number == 4000)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_4000_timer = timestamp;
		iPrintLnBold("Round 4000 : ^1" + timestamp);
	}
	else if (level.round_number == 5000)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_5000_timer = timestamp;
		iPrintLnBold("Round 5000 : ^1" + timestamp);
	}
	else if (level.round_number == 6000)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_6000_timer = timestamp;
		iPrintLnBold("Round 6000 : ^1" + timestamp);
	}
	else if (level.round_number == 7000)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_7000_timer = timestamp;
		iPrintLnBold("Round 7000 : ^1" + timestamp);
	}
	else if (level.round_number == 8000)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_8000_timer = timestamp;
		iPrintLnBold("Round 8000 : ^1" + timestamp);
	}
	else if (level.round_number == 9000)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_9000_timer = timestamp;
		iPrintLnBold("Round 9000 : ^1" + timestamp);
	}
	else if (level.round_number == 10000)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_10000_timer = timestamp;
		iPrintLnBold("Round 10000 : ^1" + timestamp);
	}
	else if (level.round_number == 11000)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_11000_timer = timestamp;
		iPrintLnBold("Round 11000 : ^1" + timestamp);
	}
	else if (level.round_number == 12000)
	{
		timestamp = convert_time(int(getTime() / 1000) - level.FRFIX_START);
		level.round_12000_timer = timestamp;
		iPrintLnBold("Round 11000 : ^1" + timestamp);
	}
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
		if ( GetDvarInt ( "sph" ) == 1)
		{
			if ( GetDvarInt ( "box_hits" ) == 1)
			{
				if ( GetDvarInt ( "round_timer" ) == 1)
				{
					if ( GetDvarInt ( "lobby_timer" ) == 1)
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
					if ( GetDvarInt ( "lobby_timer" ) == 1)
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
				if ( GetDvarInt ( "round_timer" ) == 1)
				{
					if ( GetDvarInt ( "lobby_timer" ) == 1)
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
					if ( GetDvarInt ( "lobby_timer" ) == 1)
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
			if ( GetDvarInt ( "next_dog" ) == 1)
			{
				if ( GetDvarInt ( "sph" ) == 1)
				{
					if ( GetDvarInt ( "box_hits" ) == 1)
					{
						if ( GetDvarInt ( "round_timer" ) == 1)
						{
							if ( GetDvarInt ( "lobby_timer" ) == 1)
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
							if ( GetDvarInt ( "lobby_timer" ) == 1)
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
						if ( GetDvarInt ( "round_timer" ) == 1)
						{
							if ( GetDvarInt ( "lobby_timer" ) == 1)
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
							if ( GetDvarInt ( "lobby_timer" ) == 1)
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
					if ( GetDvarInt ( "box_hits" ) == 1)
					{
						if ( GetDvarInt ( "round_timer" ) == 1)
						{
							if ( GetDvarInt ( "lobby_timer" ) == 1)
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
							if ( GetDvarInt ( "lobby_timer" ) == 1)
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
						if ( GetDvarInt ( "round_timer" ) == 1)
						{
							if ( GetDvarInt ( "lobby_timer" ) == 1)
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
							if ( GetDvarInt ( "lobby_timer" ) == 1)
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
		if ( GetDvarInt ( "hp" ) == 1)
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
		if ( GetDvarInt ( "zombie_counter" ) == 1)
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
		if ( GetDvarInt ( "box_hits" ) == 1)
		{
			if ( GetDvarInt ( "round_timer" ) == 1)
			{
				if ( GetDvarInt ( "lobby_timer" ) == 1)
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
				if ( GetDvarInt ( "lobby_timer" ) == 1)
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

		if ( GetDvarInt ( "trap_timer" ) == 1)
		{
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

		if ( GetDvarInt ( "trap_timer" ) == 1)
		{
			if (level.script == "nazi_zombie_sumpf") //snn
			{
				if(player_points == (self.score + 1500) && level.round_number > 14) //use essa função em mapas que a trap custa 1500 pontos
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
		
		if ( GetDvarInt ( "trap_timer" ) == 1)
		{
			if (level.script == "nazi_zombie_sumpf") //snn
			{
				if(player_points == (self.score + 750) && level.round_number > 14) //use essa função em mapas que a trap custa 750 pontos
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