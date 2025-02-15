--[[
Copyright © 2014, Seth VanHeulen
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

1. Redistributions of source code must retain the above copyright
notice, this list of conditions and the following disclaimer.

2. Redistributions in binary form must reproduce the above copyright
notice, this list of conditions and the following disclaimer in the
documentation and/or other materials provided with the distribution.

3. Neither the name of the copyright holder nor the names of its
contributors may be used to endorse or promote products derived from
this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]

addon.name      = 'setbgm'
addon.author    = 'Seth VanHeulen (Acacia@Odin) | Converted by Shinzaku | Ashita V4 port by Apples_mmmmmmmm'
addon.version   = '1.2.4'
addon.desc      = [[Allows you to set various types of music in the game.setbgm list [music]
                    Lists all of the available songs in the game.
                    /setbgm list type
                    Lists the different types of music you can set.
                    /setbgm <song id>
                    Sets the background music given by the ID.
                    /setbgm <song id> <music type id>
                    Sets only a given type of music.
                    /setbgm <song id> <song id> <song id> <song id> <song id> <song id> <song id> <song id>
                    Sets all types of music at once.]]
addon.link    = 'https://github.com/Applesmmmmmmmm/SetBGM';

require 'common'

local music_types = {
    [0]='Idle (Day)',
    [1]='Idle (Night)',
    [2]='Battle (Solo)',
    [3]='Battle (Party)',
    [4]='Chocobo',
    [5]='Death',
    [6]='Mog House',
    [7]='Fishing'
}

local songs = {
 [40]='Cloister of Time and Souls',
 [41]='Royal Wanderlust',
 [42]='Snowdrift Waltz',
 [43]='Troubled Shadows',
 [44]='Where Lords Rule Not',
 [45]='Summers Lost',
 [46]='Goddess Divine',
 [47]='Echoes of Creation',
 [48]='Main Theme',
 [49]='Luck of the Mog',
 [50]='Feast of the Ladies',
 [51]='Abyssea - Scarlet Skies, Shadowed Plains',
 [52]='Melodies Errant',
 [53]='Shinryu',
 [54]='Everlasting Bonds',
 [55]='Provenance Watcher',
 [56]='Where it All Begins',
 [57]='Steel Sings, Blades Dance',
 [58]='A New Direction',
 [59]='The Pioneers',
 [60]='Into Lands Primeval - Ulbuka',
 [61]="Water's Umbral Knell",
 [62]='Keepers of the Wild',
 [63]='The Sacred City of Adoulin',
 [64]='Breaking Ground',
 [65]='Hades',
 [66]='Arciela',
 [67]='Mog Resort',
 [68]='Worlds Away',
 [69]="Distant Worlds (Nanaa Mihgo's version)",
 [70]='Monstrosity',
 [71]="The Pioneers (Nanaa Mihgo's version)",
 [72]='The Serpentine Labyrinth',
 [73]='The Divine',
 [74]='Clouds Over Ulbuka',
 [75]='The Price',
 [76]='Forever Today',
 [77]='Distant Worlds (Instrumental)',
 [78]='Forever Today (Instrumental)',
 [79]='Iroha',
 [80]='The Boundless Black',
 [81]='Isle of the Gods',
 [82]='Wail of the Void',
 [83]="Rhapsodies of Vana'diel",
 [84]="Mount (Ability)",
 [85]="Ambuscade",
 [86]='Awakening (FFRK)',
 [87]='Omen - Unknown Track Title',
 [88]='Dynamis Divergence - Unknown Track Title',
 [89]='Dynamis Divergence - Unknown Track Title',
 [101]='Battle Theme',
 [102]='Battle in the Dungeon #2',
 [103]='Battle Theme #2',
 [104]='A Road Once Traveled',
 [105]='Mhaura',
 [106]='Voyager',
 [107]="The Kingdom of San d'Oria",
 [108]="Vana'diel March",
 [109]='Ronfaure',
 [110]='The Grand Duchy of Jeuno',
 [111]='Blackout',
 [112]='Selbina',
 [113]='Sarutabaruta',
 [114]='Batallia Downs',
 [115]='Battle in the Dungeon',
 [116]='Gustaberg',
 [117]="Ru'Lude Gardens",
 [118]='Rolanberry Fields',
 [119]='Awakening',
 [120]="Vana'diel March #2",
 [121]='Shadow Lord',
 [122]='One Last Time',
 [123]='Hopelessness',
 [124]='Recollection',
 [125]='Tough Battle',
 [126]='Mog House',
 [127]='Anxiety',
 [128]='Airship',
 [129]='Hook, Line and Sinker',
 [130]='Tarutaru Female',
 [131]='Elvaan Female',
 [132]='Elvaan Male',
 [133]='Hume Male',
 [134]='Yuhtunga Jungle',
 [135]='Kazham',
 [136]='The Big One',
 [137]='A Realm of Emptiness',
 [138]="Mercenaries' Delight",
 [139]='Delve',
 [140]='Wings of the Goddess',
 [141]='The Cosmic Wheel',
 [142]='Fated Strife -Besieged-',
 [143]='Hellriders',
 [144]='Rapid Onslaught -Assault-',
 [145]='Encampment Dreams',
 [146]='The Colosseum',
 [147]='Eastward Bound...',
 [148]='Forbidden Seal',
 [149]='Jeweled Boughs',
 [150]='Ululations from Beyond',
 [151]='The Federation of Windurst',
 [152]='The Republic of Bastok',
 [153]='Prelude',
 [154]='Metalworks',
 [155]='Castle Zvahl',
 [156]="Chateau d'Oraguille",
 [157]='Fury',
 [158]='Sauromugue Champaign',
 [159]='Sorrow',
 [160]='Repression (Memoro de la Stono)',
 [161]='Despair (Memoro de la Stono)',
 [162]='Heavens Tower',
 [163]='Sometime, Somewhere',
 [164]='Xarcabard',
 [165]='Galka',
 [166]='Mithra',
 [167]='Tarutaru Male',
 [168]='Hume Female',
 [169]='Regeneracy',
 [170]='Buccaneers',
 [171]='Altepa Desert',
 [172]='Black Coffin',
 [173]='Illusions in the Mist',
 [174]='Whispers of the Gods',
 [175]="Bandits' Market",
 [176]='Circuit de Chocobo',
 [177]='Run Chocobo, Run!',
 [178]='Bustle of the Capital',
 [179]="Vana'diel March #4",
 [180]='Thunder of the March',
 [181]='Dash de Chocobo (Low Quality)',
 [182]='Stargazing',
 [183]="A Puppet's Slumber",
 [184]='Eternal Gravestone',
 [185]='Ever-Turning Wheels',
 [186]='Iron Colossus',
 [187]='Ragnarok',
 [188]='Choc-a-bye Baby',
 [189]='An Invisible Crown',
 [190]="The Sanctuary of Zi'Tah",
 [191]='Battle Theme #3',
 [192]='Battle in the Dungeon #3',
 [193]='Tough Battle #2',
 [194]='Bloody Promises',
 [195]='Belief',
 [196]='Fighters of the Crystal',
 [197]='To the Heavens',
 [198]="Eald'narche",
 [199]="Grav'iton",
 [200]='Hidden Truths',
 [201]='End Theme',
 [202]='Moongate (Memoro de la Stono)',
 [203]='Ancient Verse of Uggalepih',
 [204]="Ancient Verse of Ro'Maeve",
 [205]='Ancient Verse of Altepa',
 [206]='Revenant Maiden',
 [207]="Ve'Lugannon Palace",
 [208]='Rabao',
 [209]='Norg',
 [210]="Tu'Lia",
 [211]="Ro'Maeve",
 [212]='Dash de Chocobo',
 [213]='Hall of the Gods',
 [214]='Eternal Oath',
 [215]='Clash of Standards',
 [216]='On this Blade',
 [217]='Kindred Cry',
 [218]='Depths of the Soul',
 [219]='Onslaught',
 [220]='Turmoil',
 [221]='Moblin Menagerie - Movalpolos',
 [222]='Faded Memories - Promyvion',
 [223]='Conflict: March of the Hero',
 [224]='Dusk and Dawn',
 [225]="Words Unspoken - Pso'Xja",
 [226]='Conflict: You Want to Live Forever?',
 [227]='Sunbreeze Shuffle',
 [228]="Gates of Paradise - The Garden of Ru'Hmet",
 [229]='Currents of Time',
 [230]='A New Horizon - Tavnazian Archipelago',
 [231]='Celestial Thunder',
 [232]='The Ruler of the Skies',
 [233]="The Celestial Capital - Al'Taieu",
 [234]='Happily Ever After',
 [235]='First Ode: Nocturne of the Gods',
 [236]='Fourth Ode: Clouded Dawn',
 [237]='Third Ode: Memoria de la Stona',
 [238]='A New Morning',
 [239]='Jeuno -Starlight Celebration-',
 [240]='Second Ode: Distant Promises',
 [241]='Fifth Ode: A Time for Prayer',
 [242]='Unity',
 [243]="Grav'iton",
 [244]='Revenant Maiden',
 [245]='The Forgotten City - Tavnazian Safehold',
 [246]='March of the Allied Forces',
 [247]='Roar of the Battle Drums',
 [248]='Young Griffons in Flight',
 [249]='Run Maggot, Run!',
 [250]='Under a Clouded Moon',
 [251]='Autumn Footfalls',
 [252]='Flowers on the Battlefield',
 [253]='Echoes of a Zypher',
 [254]='Griffons Never Die',
 [900]='Distant Worlds'
}

local packetManager = AshitaCore:GetPacketManager();

function SetMusic(music_type, song)
    if music_type then
        local m = tonumber(music_type);
        if music_types[m] then
            local s = tonumber(song);
            if songs[s] then
                print(string.format('\30\70[SetBGM] Setting %s music: %s', music_types[m], songs[s]));
				local newPacket = (struct.pack('bbbbhh', 0x05F, 0x01, 0x00, 0x00, m, s)):totable();
				packetManager:AddIncomingPacket(0x05F, newPacket);
            else
                print(string.format('\30\70Invalid song: %s', string.format(song)));
            end
        else
            print(string.format('\30\70Invalid music type: %s', string.format(music_type)));
        end
    else
        local s = tonumber(song);
        if songs[s] then
            print(string.format('\30\70[SetBGM] Setting all music: %s', string.format(songs[s])));
            for music_type=0,7 do
				local newPacket = (struct.pack('bbbbhh', 0x05F, 0x01, 0x00, 0x00, music_type, s)):totable();
				packetManager:AddIncomingPacket(0x05F, newPacket);
            end
        else
            print(string.format('\30\70Invalid song: %s', string.format(song)));
        end
    end
end

function DisplaySongs()
    print('[SetBGM] Available songs:');
    for id=40,900,5 do
        local output = '  ';
        for i=0,4 do
            if songs[id+i] then
                output = string.format(output .. '\30\69%s: \30\71%s, ', tostring(id+i), songs[id+i]);
            end
        end
        if output ~= '  ' then
            print(output);
        end
    end
end

function DisplayMusicTypes()
    print('[SetBGM] Available music types:');
    local output = '  ';
    for music_type=0,7 do
		output = string.format(output .. "\30\69%s: \30\71 %s, ", tostring(music_type), music_types[music_type]);
    end
    print(output);
end

function DisplayHelp()    
    print(string.format('\30\70SetBGM Command usage:'));
    print(string.format('\30\70    setbgm ?'));
    print(string.format('\30\70    setbgm list [music|type]'));
    print(string.format('\30\70    setbgm <song id> [<music type id>]'));
    print(string.format('\30\70    setbgm <song id> <song id> <song id> <song id> <song id> <song id> <song id> <song id>'));
end;

ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args();
	
	if (args[1]:lower() == "/setbgm") then
		table.remove(args, 1);
		if #args == 1 and args[1]:lower() == 'list' then
			DisplaySongs();
        elseif #args == 1 and (args[1]:lower() == '?' or args[1]:lower() == 'help')then            
            DisplayHelp();    
		elseif #args == 2 and args[1]:lower() == 'list' and args[2]:lower() == 'music' then
			DisplaySongs();
		elseif #args == 2 and args[1]:lower() == 'list' and args[2]:lower() == 'type' then
			DisplayMusicTypes();
		elseif #args == 1 then
			SetMusic(nil, args[1]);
		elseif #args == 2 then
			SetMusic(args[2], args[1]);
		elseif #args == 8 then
			SetMusic(0, args[1]);
			SetMusic(1, args[2]);
			SetMusic(2, args[3]);
			SetMusic(3, args[4]);
			SetMusic(4, args[5]);
			SetMusic(5, args[6]);
			SetMusic(6, args[7]);
			SetMusic(7, args[8]);
        else            
            DisplayHelp();
		end
        return true;
	else
		return false;
	end;
end);