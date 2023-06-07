#include maps\mp\gametypes\_hud_util;

init()
{
    setDvarIfUninitialized("killstreakCounter", 1);
    level.killstreakCounter = getDvarInt("killstreakCounter");

    setDvarIfUninitialized("playerCounter", 1);
    level.playerCounter = getDvarInt("playerCounter");
    
    level thread onPlayerConnect();
}

onPlayerConnect()
{
    for(;;)
    {
        level waittill("connected", player);    

        if( level.killstreakCounter )
            player thread killstreakPlayer();      

        // if( level.playerCounter )
            // player thread playerCounts();      
    }
}    


killstreakPlayer()
{
    level endon("game_ended");
    self endon ("disconnect");

    self.hudkillstreak = createFontString ("Objective", 1);
    self.hudkillstreak setPoint ("CENTER", "TOP", "CENTER", 20);
    self.hudkillstreak.label = &"^3 Killstreak: ^7";
    self.hudkillstreak.hideWhenInMenu = true;

    self.hudDeadDropStreak = createFontString ("Objective", 1);
    self.hudDeadDropStreak setPoint ("CENTER", "TOP", "CENTER", 30);
    self.hudDeadDropStreak.label = &"^3 Deaddrop Streak: ^7";
    self.hudDeadDropStreak.hideWhenInMenu = true;

    self.deadDeadDropReady = createFontString ("Objective", 1);
    self.deadDeadDropReady setPoint ("CENTER", "TOP", "CENTER", 40);
    self.deadDeadDropReady.label = &"^3 Is Deaddrop Ready?: ^7";
    self.deadDeadDropReady.hideWhenInMenu = true;
    
    while(true)
    {
        self.hudkillstreak setValue(self.pers["cur_kill_streak"]);
        self.hudDeadDropStreak setValue(self.pers["deadDropStreak"]);
        self.deadDeadDropReady setValue(self.pers["deadDropReady"]);
        wait 0.5;
    }
}

// playerCounts()
// {
//     level endon("game_ended");
//     self endon ("disconnect");
//     if ( level.teambased ) 
//     {
//         if(self.team == "axis")
//         {
//             self.playerCountsAxis = createFontString ("Objective", 1);
//             self.playerCountsAxis setPoint( "TOP", "LEFT", -5, -115 ); //("CENTER", "TOP", "CENTER", 20);
//             self.playerCountsAxis.label = &"^2 FRIENDS: ^7";
//             self.playerCountsAxis.hideWhenInMenu = true;

//             self.playerCountsAllies = createFontString ("Objective", 1);
//             self.playerCountsAllies setPoint( "TOP", "LEFT", -5, -100 ); //setPoint("CENTER", "TOP", "CENTER", 20);
//             self.playerCountsAllies.label = &"^1 ENEMIES: ^7";
//             self.playerCountsAllies.hideWhenInMenu = true;
//         }    
//         else
//         {
//             self.playerCountsAxis = createFontString ("Objective", 1);
//             self.playerCountsAxis setPoint( "TOP", "LEFT", -5, -100 ); //setPoint("CENTER", "TOP", "CENTER", 20);
//             self.playerCountsAxis.label = &"^1 ENEMIES: ^7";
//             self.playerCountsAxis.hideWhenInMenu = true;

//             self.playerCountsAllies = createFontString ("Objective", 1);
//             self.playerCountsAllies setPoint( "TOP", "LEFT", -5, -115 ); //setPoint("CENTER", "TOP", "CENTER", 20);
//             self.playerCountsAllies.label = &"^2 FRIENDS: ^7";
//             self.playerCountsAllies.hideWhenInMenu = true;
//         }
//     }
    
//     while(true)
//     {
//         if ( level.teambased ) 
//         {
//             self.playerCountsAllies setValue(getTeamCount("allies"));
//             self.playerCountsAxis setValue(getTeamCount("axis"));
//             wait 0.5;
//         }
//         else
//         {
//             self.playerCountsAllies setValue(getTeamCount("allies"));
//             self.playerCountsAxis setValue(getTeamCount("axis"));
//         }
//     }
// }

// getTeamCount(team) {
// 	count = 0;
// 	players = level.players;
//     for ( i = 0; i < players.size; i++ )
//     {
//         player = players[i];
// 		if(player.team == team) {
// 			count++;
// 		}
// 	}
	
// 	return count;
// }
