#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
    level.deadDropChargeTime = 10.0;

    level.deaddroptime = 10;
    level.deaddropoverlay = 0.25;

	thread onPlayerConnected();

    // watermark
    level.infoText = level createServerFontString( "Objective", 0.5 );
	level.infoText setPoint( "TOP", "RIGHT", 30, -230 );
	level.infoText setText("^7@FableServers");
	level.infoText.hidewheninmenu = true;
	// level.infoText.color = (1,0,0);
}

onPlayerConnected()
{
    level endon( "disconnect" );

	for(;;) 
    {
		level waittill( "connected", player );
        
        if(!isDefined(player.pers["cur_kill_streak"]))
            player.pers["cur_kill_streak"] = 0;
        
        if(!isDefined(player.pers["deadDropReady"]))
            player.pers["deadDropReady"] = false;
        
        player.pers["deadDropStreak"] = undefined;
        player.pers["usedDeadDropThisLife"] = false;

        player thread deadDrop();

        // shoot at your feet to suicide (disabled in Search & Destroy) - doubles as an unlimited ammo function
        player thread onWeaponFire(); 

        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    self endon( "disconnect" );
    firstSpawn = true;
    for(;;) 
    {
        self waittill("spawned_player");

        if(isDefined(self.pers["deadDropStreak"])) 
        {
            self.pers["cur_kill_streak"] = self.pers["deadDropStreak"];
            self.pers["deadDropStreak"] = undefined;
            self.pers["usedDeadDropThisLife"] = true;
        }
        else
        {
            self.pers["usedDeadDropThisLife"] = false;
        }

        //ON FIRST SPAWN
        if(firstSpawn) 
        {
            self iPrintLn("Welcome to the Dead Drop Mod!");
            firstSpawn = false;
        }
    }
}

onWeaponFire() {
    self endon( "disconnect" );
    
    for(;;) {
		self waittill( "weapon_fired" );
        weapon = self getCurrentWeapon();
        angles = self getPlayerAngles();
        /* infinite ammo */
        self giveMaxAmmo( weapon );
        /* suicide when shooting at feet with a sniper rifle */
        if ( getWeaponClass( weapon ) == "weapon_sniper" ) {
            if( angles[0] > 75 ) {
                if( level.currentGametype != "sd" ) /* disabled in Search & Destroy */
                    self suicide();
            }
        }
        wait 0.25;
    }
}

deadDrop()
{
    self endon("disconnect");
	level endon("game_ended");
    self.deaddrophud[0] = drawshader("white", "TOP", "CENTER", -190, 90, 75, 25, (0.6,0.8,0.6), 0, 1);
    self.deaddrophud[1] = drawshader("white", "TOP", "CENTER", -190, 115, 75, 10, (0,0,0), 0, 1);
    self.deaddrophud[2] = drawtext(&"0:", "TOP", "CENTER", -190, 90, 1, "bigfixed", (1,1,1), 0, 2);
    self.deaddrophud[3] = drawtext(&"deaddrop", "TOP", "CENTER", -190, 114, 1, "objective", (1,1,1), 0, 2);
    self.deaddrophud[4] = drawoverlay();
    for(;;)
    {
        event = self waittill_any_return("death", "spawned_player", "killed_enemy");
        if(event == "killed_enemy")
        {
            // self effects(); /* speed boosts for being cranked */
            // self display(true); /* overlay hud */
            // self thread timer();
            // self thread deaddropFillingUpTimer();
        }
        else if(event == "spawned_player")
        {
	        // if ( level.prematchPeriod > 0 ) {
            //     self iPrintLn( level.prematchperiod );
    		// 	wait ( level.prematchPeriod );
            // 	// level waittill("prematch_over");

            //     if( self.pers["deadDropReady"] != true /* && level.prematchPeriod == 0 */ )
            //     self thread deaddropFillingUpTimer();
            // }
            // else
            // {
            //     if( self.pers["deadDropReady"] != true /* && level.prematchPeriod == 0 */ )
            //         self thread deaddropFillingUpTimer();
            // }

        	gameFlagWait( "prematch_done" );
            if( self.pers["deadDropReady"] != true /* && level.prematchPeriod == 0 */ )
                self thread deaddropFillingUpTimer();
        } 
        else 
        {
            self display(false); /* overlay hud */
        }
    }
}


deaddropFillingUpTimer(){
    self endon("disconnect");
	level endon("game_ended");
    // self endon("death");
    // self endon("killed_enemy");
    // self endon("used_deaddrop");
    time = level.deaddroptime;
    self.deaddrophud[2] setvalue(time);
    self.deaddrophud[2].color = (1,1,1);
    self.deaddrophud[2].label = &"0:";
    //TODO: Including milliseconds would probably look nice.
    while(time != 0){
        wait 1;
        time -= 1;
        self.deaddrophud[2] setvalue(time);
        // self playlocalsound("trophy_detect_projectile");
        self playSoundToPlayer( "trophy_detect_projectile", self );
        if(time < 10){
            self.deaddrophud[2].label = &"0:0";
            if(time <= 5 && time != 0){
                self.deaddrophud[2].color = (0.8,0.2,0.2);
                // self playsound("ui_mp_suitcasebomb_timer");
                self playSoundToPlayer( "ui_mp_suitcasebomb_timer", self );
            }
        }
    }
    // self playsound("detpack_explo_default");
    self playSoundToPlayer( "fasten_seatbelts", self );
    // playfx(level.c4death, self.origin);
    // self suicide();
    self givePlayerDeadDrop();
}

/* 
timer(){
    self endon("disconnect");
	level endon("game_ended");
    self endon("death");
    self endon("killed_enemy");
    time = level.deaddroptime;
    self.deaddrophud[2] setvalue(time);
    self.deaddrophud[2].color = (1,1,1);
    self.deaddrophud[2].label = &"0:";
    //TODO: Including milliseconds would probably look nice.
    while(time != 0){
        wait 1;
        time -= 1;
        self.deaddrophud[2] setvalue(time);
        self playlocalsound("trophy_detect_projectile");
        if(time < 10){
            self.deaddrophud[2].label = &"0:0";
            if(time <= 5 && time != 0){
                self.deaddrophud[2].color = (0.8,0.2,0.2);
                self playsound("ui_mp_suitcasebomb_timer");
            }
        }
    }
    self playsound("detpack_explo_default");
    playfx(level.c4death, self.origin);
    self suicide();
} */

effects(){
    self setperk("specialty_fastermelee", true, false);
    self setperk("specialty_lightweight", true, false);
    self setperk("specialty_fastreload", true, false);
    self setperk("specialty_longersprint", true, false);
    self setperk("specialty_quickdraw", true, false);
    self setperk("specialty_stalker", true, false);
    self setperk("specialty_fastsprintrecovery", true, false);
    self setperk("specialty_fastoffhand", true, false);
    self setperk("specialty_quickswap", true, false);
    self.moveSpeedScaler = 1.2;
    self maps\mp\gametypes\_weapons::updateMoveSpeedScale();
}

display(visible){
    if(visible){
        self.deaddrophud[0].alpha = 0.5;
        self.deaddrophud[1].alpha = 0.5;
        self.deaddrophud[2].alpha = 1;
        self.deaddrophud[3].alpha = 1;
        self.deaddrophud[4].alpha = level.deaddropoverlay;
    }else{
        self.deaddrophud[0].alpha = 0;
        self.deaddrophud[1].alpha = 0;
        self.deaddrophud[2].alpha = 0;
        self.deaddrophud[3].alpha = 0;
        self.deaddrophud[4].alpha = 0;
    }
}

drawtext(text, align, relative, x, y, fontscale, font, color, alpha, sort){
    element = self createfontstring(font, fontscale);
    element setpoint(align, relative, x, y);
    element.label = text;
    element.hidewheninmenu = true;
    element.color = color;
    element.alpha = alpha;
    element.sort = sort;
    element.hidden = true;
    return element;
} 

drawshader(shader, align, relative, x, y, width, height, color, alpha, sort){
    element = newclienthudelem(self);
    element.elemtype = "icon";
    element.hidewheninmenu = true;
    element.shader = shader;
    element.width = width;
    element.height = height;
    element.align = align;
    element.relative = relative;
    element.xoffset = 0;
    element.yoffset = 0;
    element.children = [];
    element.sort = sort;
    element.color = color;
    element.alpha = alpha;
    element setparent(level.uiparent);
    element setshader(shader, width, height);
    element setpoint(align, relative, x, y);
    return element;
}

drawoverlay(){
    element = newclienthudelem(self);
	element.x = 0;
	element.y = 0;
	element.alignX = "left";
	element.alignY = "top";
	element.horzAlign = "fullscreen";
	element.vertAlign = "fullscreen";
	element setshader ("combathigh_overlay", 640, 480);
	element.sort = -10;
    element.alpha = 0;
    element.color = (0,1,0);
    return element;
}

givePlayerDeadDrop()
{
    self thread ddBind();
    self.pers["deadDropReady"] = true;
    self iPrintLnBold( "Dead Drop Ready! Press [{+actionslot 1}]");
}

ddBind()
{
	self notifyOnPlayerCommand("actionslot1", "+actionslot 1");
    for(;;)
	{
        self waittill("actionslot1");

        if( self.pers["deadDropReady"] == true && self.pers["usedDeadDropThisLife"] != true && isAlive(self))
        {
            self.pers["deadDropStreak"] = self.pers["cur_kill_streak"];
            self.pers["deadDropReady"] = false;
        }
        
        if( self.pers["usedDeadDropThisLife"] == true )
        {
            self iPrintLnBold( "You cannot save the same killstreak twice, wait until your next respawn" );
        }

        if(!isAlive(self))
        {
            self iPrintLn( "You must be alive to use Dead Drop" );
        }
    }
}

/* while(isAlive(self))
    {
        if(self.pers["deadDropReady"] == false)
        {
            wait level.deaddroptime;
            self _deadDrop();
        }
    }
    wait 0.02; */