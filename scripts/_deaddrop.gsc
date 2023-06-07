#include common_scripts\utility;
#include maps\mp\_utility;
#include maps\mp\gametypes\_hud_util;

init()
{
    level.deaddropbind = "+actionslot 1";
    level.deaddropbindVISUAL = "[{+actionslot 1}]";
    level.deaddroptime = 10;
    level.deaddropoverlay = 0.25;

	thread onPlayerConnected();

    // watermark
    level.infoText = level createServerFontString( "Objective", 0.5 );
	level.infoText setPoint( "TOP", "RIGHT", 30, -230 );
	level.infoText setText("^7@FableServers");
	level.infoText.hidewheninmenu = true;
	// level.infoText.color = (1,0,0);

    exec( "spawnBot 12" );
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
        player.ddTime = undefined;
        player.pers["usedDeadDropThisLife"] = false;

        player thread deadDrop();

        // shoot at your feet to suicide (disabled in Search & Destroy) - doubles as an unlimited ammo function
        player thread onWeaponFire(); 
        player thread ddBind();
        player thread manageBind(); 

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

manageBind()
{
    self endon( "disconnect" );
    
    for(;;) {
		self waittill_any( "changed_kit", "changed_class", "spawned_player" );

        if( level.deaddropbind == "+actionslot 1" ) {
            self maps\mp\_utility::_setactionslot( 1, "" );
        }
        wait 0.1;
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
        if(event == "spawned_player")
        {
            /* wait until game starts to allow dead drop countdown to begin */
        	// gameFlagWait( "prematch_done" );
        	gameFlagWait( "dead_drop" );

            if(isDefined(self.ddTime))
                self thread deaddropFillingUpTimer();

            /* If Dead Drop is not ready for use, turn on the display and allow the countdown to begin */
            if( self.pers["deadDropReady"] != true && self.pers["refilling"] == false ) {
                self display(true); /* overlay & hud ON */
                self thread deaddropFillingUpTimer();
            }

            /* If Dead Drop is ready for use, turn off the display */
            if( self.pers["deadDropReady"] == true ) {
                self display(false); /* overlay & hud OFF */
            }
        } 
        if(event == "death")
        {
            /* idk */
        }
        else 
        {
            /* idk */
        }
    }
}

deaddropFillingUpTimer()
{
    self endon("disconnect");
    self endon("death");
	level endon("game_ended");

    time = level.deaddroptime;

    if(isDefined(self.ddTime)) {
        time = self.ddTime;
    }

    self.deaddrophud[2] setvalue(time);

    if(isDefined(self.ddTime) && self.ddTime < 10)
    {
        self.deaddrophud[2].label = &"0:0";
    }
    else
    {
        self.deaddrophud[2].label = &"0:"; //TODO: Including milliseconds would probably look nice.
    }

    if(isDefined(self.ddTime) && self.ddTime <= 5 && self.ddTime != 0) {
        self.deaddrophud[2].color = (0.8,0.2,0.2);
    }
    else
    {
        self.deaddrophud[2].color = (1,1,1);
    }

    while( time != 0 )
    {
        self.pers["refilling"] = true;
        wait 1;
        time -= 1;
        self.deaddrophud[2] setvalue(time);
        self.ddTime = time;
        self playSoundToPlayer( "trophy_detect_projectile", self );
        if(time < 10){
            self.deaddrophud[2].label = &"0:0";
            if(time <= 5 && time != 0){
                self.deaddrophud[2].color = (0.8,0.2,0.2);
                self playSoundToPlayer( "ui_mp_suitcasebomb_timer", self );
            }
        }
    }
    self __givePlayerDeadDrop();
}

__givePlayerDeadDrop()
{
    self playSoundToPlayer( "fasten_seatbelts", self );
    self givePlayerDeadDrop();
    self.ddTime = undefined;
}

givePlayerDeadDrop()
{
    // self thread ddBind(); // moved this to onPlayerConnected()
    self.pers["deadDropReady"] = true;
    self.pers["refilling"] = false;
    self iPrintLnBold( "Dead Drop Ready! Press ^3" + level.deaddropbindVISUAL);
    self display(false); /* overlay & hud OFF */
}

ddBind()
{
    self endon( "dead_drop_done" );
	self notifyOnPlayerCommand("useDeadDrop", level.deaddropbind );
    for(;;)
	{
        self waittill("useDeadDrop");

        if(self.pers["cur_kill_streak"] < 1 ) { /* ignore */ }
        else
        {
            if( self.pers["deadDropReady"] == true && self.pers["usedDeadDropThisLife"] != true && isAlive(self))
            {
                self.pers["deadDropStreak"] = self.pers["cur_kill_streak"];
                self.pers["deadDropReady"] = false;
            }
            
            if( self.pers["deadDropReady"] == true && self.pers["usedDeadDropThisLife"] == true )
            {
                self iPrintLnBold( "You cannot save the same killstreak twice, wait until your next respawn" );
            }

            if(self.pers["deadDropReady"] == true && !isAlive(self))
            {
                self iPrintLn( "You must be alive to use Dead Drop" );
            }
        }
    }
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
