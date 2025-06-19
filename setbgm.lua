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
                    Sets the volume of the music in the game.
                    /setbgm [volume|vol] [0-127]/
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

local music_id_to_type = {
    [0]='Idle (Day)',
    [1]='Idle (Night)',
    [2]='Battle (Solo)',
    [3]='Battle (Party)',
    [4]='Chocobo',
    [5]='Death',
    [6]='Mog House',
    [7]='Fishing'
}

local music_types_sorted = {
    {3, 'Battle (Party)'},
    {2, 'Battle (Solo)'},
    {4, 'Chocobo'},
    {5, 'Death'},
    {7, 'Fishing'},
    {0, 'Idle (Day)'},
    {1, 'Idle (Night)'},
    {6, 'Mog House'},
}

local song_id_to_name = {
    [58]  = 'A New Direction',
    [230] = 'A New Horizon - Tavnazian Archipelago',
    [238] = 'A New Morning',
    [183] = 'A Puppet\'s Slumber',
    [137] = 'A Realm of Emptiness',
    [104] = 'A Road Once Traveled',
    [51]  = 'Abyssea - Scarlet Skies, Shadowed Plains',
    [128] = 'Airship',
    [171] = 'Altepa Desert',
    [85]  = 'Ambuscade',
    [189] = 'An Invisible Crown',
    [205] = 'Ancient Verse of Altepa',
    [204] = 'Ancient Verse of Ro\'Maeve',
    [203] = 'Ancient Verse of Uggalepih',
    [127] = 'Anxiety',
    [66]  = 'Arciela',
    [251] = 'Autumn Footfalls',
    [119] = 'Awakening',
    [86]  = 'Awakening (FFRK)',
    [175] = 'Bandits\' Market',
    [114] = 'Batallia Downs',
    [101] = 'Battle Theme',
    [103] = 'Battle Theme #2',
    [191] = 'Battle Theme #3',
    [115] = 'Battle in the Dungeon',
    [102] = 'Battle in the Dungeon #2',
    [192] = 'Battle in the Dungeon #3',
    [195] = 'Belief',
    [172] = 'Black Coffin',
    [111] = 'Blackout',
    [194] = 'Bloody Promises',
    [64]  = 'Breaking Ground',
    [170] = 'Buccaneers',
    [178] = 'Bustle of the Capital',
    [155] = 'Castle Zvahl',
    [231] = 'Celestial Thunder',
    [156] = 'Chateau d\'Oraguille',
    [188] = 'Choc-a-bye Baby',
    [176] = 'Circuit de Chocobo',
    [215] = 'Clash of Standards',
    [40]  = 'Cloister of Time and Souls',
    [74]  = 'Clouds Over Ulbuka',
    [223] = 'Conflict: March of the Hero',
    [226] = 'Conflict: You Want to Live Forever?',
    [229] = 'Currents of Time',
    [212] = 'Dash de Chocobo',
    [181] = 'Dash de Chocobo (Low Quality)',
    [139] = 'Delve',
    [218] = 'Depths of the Soul',
    [161] = 'Despair (Memoro de la Stono)',
    [900] = 'Distant Worlds',
    [77]  = 'Distant Worlds (Instrumental)',
    [69]  = 'Distant Worlds (Nanaa Mihgo\'s version)',
    [224] = 'Dusk and Dawn',
    [89]  = 'Dynamis Divergence - Unknown Track Title',
    [88]  = 'Dynamis Divergence - Unknown Track Title',
    [198] = 'Eald\'narche',
    [147] = 'Eastward Bound...',
    [47]  = 'Echoes of Creation',
    [253] = 'Echoes of a Zypher',
    [131] = 'Elvaan Female',
    [132] = 'Elvaan Male',
    [145] = 'Encampment Dreams',
    [201] = 'End Theme',
    [184] = 'Eternal Gravestone',
    [214] = 'Eternal Oath',
    [185] = 'Ever-Turning Wheels',
    [54]  = 'Everlasting Bonds',
    [222] = 'Faded Memories - Promyvion',
    [142] = 'Fated Strife -Besieged-',
    [50]  = 'Feast of the Ladies',
    [241] = 'Fifth Ode: A Time for Prayer',
    [196] = 'Fighters of the Crystal',
    [235] = 'First Ode: Nocturne of the Gods',
    [252] = 'Flowers on the Battlefield',
    [148] = 'Forbidden Seal',
    [76]  = 'Forever Today',
    [78]  = 'Forever Today (Instrumental)',
    [236] = 'Fourth Ode: Clouded Dawn',
    [157] = 'Fury',
    [165] = 'Galka',
    [228] = 'Gates of Paradise - The Garden of Ru\'Hmet',
    [46]  = 'Goddess Divine',
    [243] = 'Grav\'iton',
    [199] = 'Grav\'iton',
    [254] = 'Griffons Never Die',
    [116] = 'Gustaberg',
    [65]  = 'Hades',
    [213] = 'Hall of the Gods',
    [234] = 'Happily Ever After',
    [162] = 'Heavens Tower',
    [143] = 'Hellriders',
    [200] = 'Hidden Truths',
    [129] = 'Hook, Line and Sinker',
    [123] = 'Hopelessness',
    [168] = 'Hume Female',
    [133] = 'Hume Male',
    [173] = 'Illusions in the Mist',
    [60]  = 'Into Lands Primeval - Ulbuka',
    [79]  = 'Iroha',
    [186] = 'Iron Colossus',
    [81]  = 'Isle of the Gods',
    [239] = 'Jeuno -Starlight Celebration-',
    [149] = 'Jeweled Boughs',
    [135] = 'Kazham',
    [62]  = 'Keepers of the Wild',
    [217] = 'Kindred Cry',
    [49]  = 'Luck of the Mog',
    [48]  = 'Main Theme',
    [246] = 'March of the Allied Forces',
    [52]  = 'Melodies Errant',
    [138] = 'Mercenaries\' Delight',
    [154] = 'Metalworks',
    [105] = 'Mhaura',
    [166] = 'Mithra',
    [221] = 'Moblin Menagerie - Movalpolos',
    [126] = 'Mog House',
    [67]  = 'Mog Resort',
    [70]  = 'Monstrosity',
    [202] = 'Moongate (Memoro de la Stono)',
    [84]  = 'Mount (Ability)',
    [209] = 'Norg',
    [87]  = 'Omen - Unknown Track Title',
    [216] = 'On this Blade',
    [122] = 'One Last Time',
    [219] = 'Onslaught',
    [153] = 'Prelude',
    [55]  = 'Provenance Watcher',
    [208] = 'Rabao',
    [187] = 'Ragnarok',
    [144] = 'Rapid Onslaught -Assault-',
    [124] = 'Recollection',
    [169] = 'Regeneracy',
    [160] = 'Repression (Memoro de la Stono)',
    [206] = 'Revenant Maiden',
    [244] = 'Revenant Maiden',
    [83]  = 'Rhapsodies of Vana\'diel',
    [211] = 'Ro\'Maeve',
    [247] = 'Roar of the Battle Drums',
    [118] = 'Rolanberry Fields',
    [109] = 'Ronfaure',
    [41]  = 'Royal Wanderlust',
    [117] = 'Ru\'Lude Gardens',
    [177] = 'Run Chocobo, Run!',
    [249] = 'Run Maggot, Run!',
    [113] = 'Sarutabaruta',
    [158] = 'Sauromugue Champaign',
    [240] = 'Second Ode: Distant Promises',
    [112] = 'Selbina',
    [121] = 'Shadow Lord',
    [53]  = 'Shinryu',
    [42]  = 'Snowdrift Waltz',
    [163] = 'Sometime, Somewhere',
    [159] = 'Sorrow',
    [182] = 'Stargazing',
    [57]  = 'Steel Sings, Blades Dance',
    [45]  = 'Summers Lost',
    [227] = 'Sunbreeze Shuffle',
    [130] = 'Tarutaru Female',
    [167] = 'Tarutaru Male',
    [136] = 'The Big One',
    [80]  = 'The Boundless Black',
    [233] = 'The Celestial Capital - Al\'Taieu',
    [146] = 'The Colosseum',
    [141] = 'The Cosmic Wheel',
    [73]  = 'The Divine',
    [151] = 'The Federation of Windurst',
    [245] = 'The Forgotten City - Tavnazian Safehold',
    [110] = 'The Grand Duchy of Jeuno',
    [107] = 'The Kingdom of San d\'Oria',
    [59]  = 'The Pioneers',
    [71]  = 'The Pioneers (Nanaa Mihgo\'s version)',
    [75]  = 'The Price',
    [152] = 'The Republic of Bastok',
    [232] = 'The Ruler of the Skies',
    [63]  = 'The Sacred City of Adoulin',
    [190] = 'The Sanctuary of Zi\'Tah',
    [72]  = 'The Serpentine Labyrinth',
    [237] = 'Third Ode: Memoria de la Stona',
    [180] = 'Thunder of the March',
    [197] = 'To the Heavens',
    [125] = 'Tough Battle',
    [193] = 'Tough Battle #2',
    [43]  = 'Troubled Shadows',
    [210] = 'Tu\'Lia',
    [220] = 'Turmoil',
    [150] = 'Ululations from Beyond',
    [250] = 'Under a Clouded Moon',
    [242] = 'Unity',
    [108] = 'Vana\'diel March',
    [120] = 'Vana\'diel March #2',
    [179] = 'Vana\'diel March #4',
    [207] = 'Ve\'Lugannon Palace',
    [106] = 'Voyager',
    [82]  = 'Wail of the Void',
    [61]  = 'Water\'s Umbral Knell',
    [44]  = 'Where Lords Rule Not',
    [56]  = 'Where it All Begins',
    [174] = 'Whispers of the Gods',
    [140] = 'Wings of the Goddess',
    [225] = 'Words Unspoken - Pso\'Xja',
    [68]  = 'Worlds Away',
    [164] = 'Xarcabard',
    [248] = 'Young Griffons in Flight',
    [134] = 'Yuhtunga Jungle'
};

local songs_sorted = {
    {58,  'A New Direction'},
    {230, 'A New Horizon - Tavnazian Archipelago'},
    {238, 'A New Morning'},
    {183, 'A Puppet\'s Slumber'},
    {137, 'A Realm of Emptiness'},
    {104, 'A Road Once Traveled'},
    {51,  'Abyssea - Scarlet Skies, Shadowed Plains'},
    {128, 'Airship'},
    {171, 'Altepa Desert'},
    {85,  'Ambuscade'},
    {189, 'An Invisible Crown'},
    {205, 'Ancient Verse of Altepa'},
    {204, 'Ancient Verse of Ro\'Maeve'},
    {203, 'Ancient Verse of Uggalepih'},
    {127, 'Anxiety'},
    {66,  'Arciela'},
    {251, 'Autumn Footfalls'},
    {119, 'Awakening'},
    {86,  'Awakening (FFRK)'},
    {175, 'Bandits\' Market'},
    {114, 'Batallia Downs'},
    {101, 'Battle Theme'},
    {103, 'Battle Theme #2'},
    {191, 'Battle Theme #3'},
    {115, 'Battle in the Dungeon'},
    {102, 'Battle in the Dungeon #2'},
    {192, 'Battle in the Dungeon #3'},
    {195, 'Belief'},
    {172, 'Black Coffin'},
    {111, 'Blackout'},
    {194, 'Bloody Promises'},
    {64,  'Breaking Ground'},
    {170, 'Buccaneers'},
    {178, 'Bustle of the Capital'},
    {155, 'Castle Zvahl'},
    {231, 'Celestial Thunder'},
    {156, 'Chateau d\'Oraguille'},
    {188, 'Choc-a-bye Baby'},
    {176, 'Circuit de Chocobo'},
    {215, 'Clash of Standards'},
    {40,  'Cloister of Time and Souls'},
    {74,  'Clouds Over Ulbuka'},
    {223, 'Conflict: March of the Hero'},
    {226, 'Conflict: You Want to Live Forever?'},
    {229, 'Currents of Time'},
    {212, 'Dash de Chocobo'},
    {181, 'Dash de Chocobo (Low Quality)'},
    {139, 'Delve'},
    {218, 'Depths of the Soul'},
    {161, 'Despair (Memoro de la Stono)'},
    {900, 'Distant Worlds'},
    {77,  'Distant Worlds (Instrumental)'},
    {69,  'Distant Worlds (Nanaa Mihgo\'s version)'},
    {224, 'Dusk and Dawn'},
    {89,  'Dynamis Divergence - Unknown Track Title'},
    {88,  'Dynamis Divergence - Unknown Track Title'},
    {198, 'Eald\'narche'},
    {147, 'Eastward Bound...'},
    {47,  'Echoes of Creation'},
    {253, 'Echoes of a Zypher'},
    {131, 'Elvaan Female'},
    {132, 'Elvaan Male'},
    {145, 'Encampment Dreams'},
    {201, 'End Theme'},
    {184, 'Eternal Gravestone'},
    {214, 'Eternal Oath'},
    {185, 'Ever-Turning Wheels'},
    {54,  'Everlasting Bonds'},
    {222, 'Faded Memories - Promyvion'},
    {142, 'Fated Strife -Besieged-'},
    {50,  'Feast of the Ladies'},
    {241, 'Fifth Ode: A Time for Prayer'},
    {196, 'Fighters of the Crystal'},
    {235, 'First Ode: Nocturne of the Gods'},
    {252, 'Flowers on the Battlefield'},
    {148, 'Forbidden Seal'},
    {76,  'Forever Today'},
    {78,  'Forever Today (Instrumental)'},
    {236, 'Fourth Ode: Clouded Dawn'},
    {157, 'Fury'},
    {165, 'Galka'},
    {228, 'Gates of Paradise - The Garden of Ru\'Hmet'},
    {46,  'Goddess Divine'},
    {243, 'Grav\'iton'},
    {199, 'Grav\'iton'},
    {254, 'Griffons Never Die'},
    {116, 'Gustaberg'},
    {65,  'Hades'},
    {213, 'Hall of the Gods'},
    {234, 'Happily Ever After'},
    {162, 'Heavens Tower'},
    {143, 'Hellriders'},
    {200, 'Hidden Truths'},
    {129, 'Hook, Line and Sinker'},
    {123, 'Hopelessness'},
    {168, 'Hume Female'},
    {133, 'Hume Male'},
    {173, 'Illusions in the Mist'},
    {60,  'Into Lands Primeval - Ulbuka'},
    {79,  'Iroha'},
    {186, 'Iron Colossus'},
    {81,  'Isle of the Gods'},
    {239, 'Jeuno -Starlight Celebration-'},
    {149, 'Jeweled Boughs'},
    {135, 'Kazham'},
    {62,  'Keepers of the Wild'},
    {217, 'Kindred Cry'},
    {49,  'Luck of the Mog'},
    {48,  'Main Theme'},
    {246, 'March of the Allied Forces'},
    {52,  'Melodies Errant'},
    {138, 'Mercenaries\' Delight'},
    {154, 'Metalworks'},
    {105, 'Mhaura'},
    {166, 'Mithra'},
    {221, 'Moblin Menagerie - Movalpolos'},
    {126, 'Mog House'},
    {67,  'Mog Resort'},
    {70,  'Monstrosity'},
    {202, 'Moongate (Memoro de la Stono)'},
    {84,  'Mount (Ability)'},
    {209, 'Norg'},
    {87,  'Omen - Unknown Track Title'},
    {216, 'On this Blade'},
    {122, 'One Last Time'},
    {219, 'Onslaught'},
    {153, 'Prelude'},
    {55,  'Provenance Watcher'},
    {208, 'Rabao'},
    {187, 'Ragnarok'},
    {144, 'Rapid Onslaught -Assault-'},
    {124, 'Recollection'},
    {169, 'Regeneracy'},
    {160, 'Repression (Memoro de la Stono)'},
    {206, 'Revenant Maiden'},
    {244, 'Revenant Maiden'},
    {83,  'Rhapsodies of Vana\'diel'},
    {211, 'Ro\'Maeve'},
    {247, 'Roar of the Battle Drums'},
    {118, 'Rolanberry Fields'},
    {109, 'Ronfaure'},
    {41,  'Royal Wanderlust'},
    {117, 'Ru\'Lude Gardens'},
    {177, 'Run Chocobo, Run!'},
    {249, 'Run Maggot, Run!'},
    {113, 'Sarutabaruta'},
    {158, 'Sauromugue Champaign'},
    {240, 'Second Ode: Distant Promises'},
    {112, 'Selbina'},
    {121, 'Shadow Lord'},
    {53,  'Shinryu'},
    {42,  'Snowdrift Waltz'},
    {163, 'Sometime, Somewhere'},
    {159, 'Sorrow'},
    {182, 'Stargazing'},
    {57,  'Steel Sings, Blades Dance'},
    {45,  'Summers Lost'},
    {227, 'Sunbreeze Shuffle'},
    {130, 'Tarutaru Female'},
    {167, 'Tarutaru Male'},
    {136, 'The Big One'},
    {80,  'The Boundless Black'},
    {233, 'The Celestial Capital - Al\'Taieu'},
    {146, 'The Colosseum'},
    {141, 'The Cosmic Wheel'},
    {73,  'The Divine'},
    {151, 'The Federation of Windurst'},
    {245, 'The Forgotten City - Tavnazian Safehold'},
    {110, 'The Grand Duchy of Jeuno'},
    {107, 'The Kingdom of San d\'Oria'},
    {59,  'The Pioneers'},
    {71,  'The Pioneers (Nanaa Mihgo\'s version)'},
    {75,  'The Price'},
    {152, 'The Republic of Bastok'},
    {232, 'The Ruler of the Skies'},
    {63,  'The Sacred City of Adoulin'},
    {190, 'The Sanctuary of Zi\'Tah'},
    {72,  'The Serpentine Labyrinth'},
    {237, 'Third Ode: Memoria de la Stona'},
    {180, 'Thunder of the March'},
    {197, 'To the Heavens'},
    {125, 'Tough Battle'},
    {193, 'Tough Battle #2'},
    {43,  'Troubled Shadows'},
    {210, 'Tu\'Lia'},
    {220, 'Turmoil'},
    {150, 'Ululations from Beyond'},
    {250, 'Under a Clouded Moon'},
    {242, 'Unity'},
    {108, 'Vana\'diel March'},
    {120, 'Vana\'diel March #2'},
    {179, 'Vana\'diel March #4'},
    {207, 'Ve\'Lugannon Palace'},
    {106, 'Voyager'},
    {82,  'Wail of the Void'},
    {61,  'Water\'s Umbral Knell'},
    {44,  'Where Lords Rule Not'},
    {56,  'Where it All Begins'},
    {174, 'Whispers of the Gods'},
    {140, 'Wings of the Goddess'},
    {225, 'Words Unspoken - Pso\'Xja'},
    {68,  'Worlds Away'},
    {164, 'Xarcabard'},
    {248, 'Young Griffons in Flight'},
    {134, 'Yuhtunga Jungle'}
};
local packetManager = AshitaCore:GetPacketManager();

function add_music_packet(music_type, song_id)
    -- GP_SERV_COMMAND_MUSIC
    local op_code = 0x05F;
    local size = 0x08;
    local sync = 0x0000;
    packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, music_type, song_id):totable());
end

function set_music(music_type, song_id)
    music_type = tonumber(music_type);
    song_id = tonumber(song_id);
    if not song_id_to_name[song_id] then print(string.format('\30\70Invalid song_id: %s', string.format(song_id))); end;

    if not music_type then
        for m_type = 0, 7 do
            add_music_packet(m_type, song_id);
        end
    elseif not music_id_to_type[music_type] then print(string.format('\30\70Invalid music type: %s', string.format(music_type)));
    else
        add_music_packet(music_type, song_id);
    end
end

-- 0-127
function set_volume(newVol)
    newVol = tonumber(newVol):clamp(0, 127);
    local timeToReachVolume = 0;
    local op_code = 0x060;
    local size = 0x08;
    local sync = 0x0000;
    -- GP_SERV_COMMAND_MUSIC
    packetManager:AddIncomingPacket(0x060, struct.pack('BBHHH', op_code, size, sync, timeToReachVolume, newVol):totable());
end

function display_songs()
    print('[SetBGM] Available songs:');
    for i, song in ipairs(songs_sorted) do
        print(song[2].. ' - (ID: ' .. song[1]..')');
    end
end

function display_music_types()
    print('[SetBGM] Available music types:');
    for i, music_type in ipairs(music_types_sorted) do
        print(music_type[2].. ' - (ID: ' .. music_type[1]..')');
    end
end

function display_help()
    print(string.format('\30\70SetBGM Command usage:'));
    print(string.format('\30\70    setbgm ?'));
    print(string.format('\30\70    setbgm [volume|vol] [0-127]'));
    print(string.format('\30\70    setbgm list [music|type]'));
    print(string.format('\30\70    setbgm <song id> [<music type id>]'));
    print(string.format('\30\70    setbgm <song id> <song id> <song id> <song id> <song id> <song id> <song id> <song id>'));
end;

ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args();
    
    if (args[1]:lower() == "/setbgm") then
        table.remove(args, 1);
        if #args == 1 and args[1]:lower() == 'list' then
            display_songs();
        elseif #args == 1 and (args[1]:lower() == '?' or args[1]:lower() == 'help')then
            display_help();
        elseif #args == 2 and args[1]:lower() == 'list' and args[2]:lower() == 'music' then
            display_songs();
        elseif #args == 2 and args[1]:lower() == 'list' and args[2]:lower() == 'type' then
            display_music_types();
        elseif #args == 2 and (args[1]:lower() == 'volume' or args[1]:lower() == 'vol') then
            set_volume(args[2]);
        elseif #args == 1 then
            set_music(nil, args[1]);
        elseif #args == 2 then
            set_music(args[2], args[1]);
        elseif #args == 8 then
            for i = 0, 7 do
                set_music(i, args[i+1]);
            end
        else
            display_help();
        end
        return true;
    else
        return false;
    end;
end);

