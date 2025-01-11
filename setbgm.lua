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

local imgui = require('imgui');
require('common');

local music_types = {
    [0] = 'Idle (Day)',
    [1] = 'Idle (Night)',
    [2] = 'Battle (Solo)',
    [3] = 'Battle (Party)',
    [4] = 'Chocobo',
    [5] = 'Death',
    [6] = 'Mog House',
    [7] = 'Fishing'
};

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
};

-- Sort songs alphabetically
local sorted_songs = {};
for id, name in pairs(songs) do
    table.insert(sorted_songs, { id = id, name = name });
end

table.sort(sorted_songs, function(a, b) return a.name < b.name end);

local selected_music_type = 0;
local selected_song = sorted_songs[1].id;
local apply_to_all = true; -- Default to true
local is_open = false;
local is_zoning = false;
local dropdown_search_filter = "";

local function SetMusicPacket(music_type, song)
    local packetManager = AshitaCore:GetPacketManager();
    local newPacket = (struct.pack('bbbbhh', 0x05F, 0x01, 0x00, 0x00, music_type, song)):totable();
    packetManager:AddIncomingPacket(0x05F, newPacket);
end

-- Packet handler for zone-in and music updates
ashita.events.register('packet_in', 'packet_in_cb', function(e)
    if (e.id == 0x0A) then
        print('Zone in detected. Resetting to selected music.');
        is_zoning = true;
        if apply_to_all then
            for music_type = 0, 7 do
                SetMusicPacket(music_type, selected_song);
            end
        else
            SetMusicPacket(selected_music_type, selected_song);
        end
    end
    if (e.id == 0x5F and not is_zoning) then
        local current_music_type = struct.unpack('b', e.data, 0x04 + 1);
        local current_song = struct.unpack('H', e.data, 0x06 + 1);

        if selected_song ~= current_song then
            print(string.format('Intercepted Music Update: Changing from %s to %s.', songs[current_song] or 'Unknown', songs[selected_song]));
            ashita.bits.pack_be(e.data_modified_raw, 0x06 * 8, 16, selected_song);
        end
    end
end);

-- Blue and White Theme Styles
local function PushBlueWhiteStyles()
    imgui.PushStyleColor(ImGuiCol_Text,                {0.75, 0.75, 0.75, 1.0});  -- Silver text
    imgui.PushStyleColor(ImGuiCol_WindowBg,            {0.2, 0.2, 0.2, 1.0});  -- Dark grey background
    imgui.PushStyleColor(ImGuiCol_Button,              {0.3, 0.5, 0.7, 1.0});  -- Soft blue button
    imgui.PushStyleColor(ImGuiCol_ButtonHovered,       {0.4, 0.6, 0.8, 1.0});  -- Lighter blue hover
    imgui.PushStyleColor(ImGuiCol_ButtonActive,        {0.5, 0.7, 0.9, 1.0});  -- Bright blue active button
    imgui.PushStyleColor(ImGuiCol_FrameBg,             {0.3, 0.3, 0.3, 1.0});  -- Darker grey frame background
    imgui.PushStyleColor(ImGuiCol_FrameBgHovered,      {0.4, 0.4, 0.4, 1.0});  -- Slightly lighter grey on hover
    imgui.PushStyleColor(ImGuiCol_FrameBgActive,       {0.5, 0.5, 0.5, 1.0});  -- Even lighter grey when active
    imgui.PushStyleColor(ImGuiCol_TitleBg,             {0.1, 0.3, 0.5, 1.0});  -- Dark blue title background
    imgui.PushStyleColor(ImGuiCol_TitleBgActive,       {0.2, 0.4, 0.6, 1.0});  -- Active blue for title
    imgui.PushStyleColor(ImGuiCol_TitleBgCollapsed,    {0.2, 0.2, 0.2, 0.5});  -- Faded dark grey for collapsed title
    imgui.PushStyleColor(ImGuiCol_Border,              {0.3, 0.5, 0.7, 1.0});  -- Blue border
    imgui.PushStyleColor(ImGuiCol_Separator,           {0.3, 0.5, 0.8, 1.0});  -- Blue separators
end

local function PopBlueWhiteStyles()
    for i = 1, 13 do
        imgui.PopStyleColor();
    end
end

-- Render the IMGUI window
ashita.events.register('d3d_present', 'present_callback', function()
    -- If our window is not supposed to be open, do nothing.
    if not is_open then
        return
    end

    PushBlueWhiteStyles()

    -- Window flags:
    -- ImGuiWindowFlags_AlwaysAutoResize => auto-resize to fit content
    -- ImGuiWindowFlags_NoCollapse       => hides the collapse arrow
    local windowFlags = bit.bor(ImGuiWindowFlags_AlwaysAutoResize, ImGuiWindowFlags_NoCollapse)

    -- Optionally set constraints so the window starts small but can grow:
    imgui.SetNextWindowSizeConstraints({200, 100}, {600, 800})

    -- Create a table containing our boolean so ImGui can update it if "X" is clicked.
    local is_open_ref = { is_open }

    -- IMPORTANT: pass is_open_ref (not is_open) to imgui.Begin
    if imgui.Begin('Set Background Music', is_open_ref, windowFlags) then

        -- Apply to all checkbox
        local apply_to_all_ref = { apply_to_all }
        if imgui.Checkbox('Apply to All Music Types', apply_to_all_ref) then
            apply_to_all = apply_to_all_ref[1]
        end

        -- Music type dropdown (disabled if Apply to All is checked)
        if not apply_to_all then
            if imgui.BeginCombo('Music Type', music_types[selected_music_type] or 'Unknown') then
                for k, v in pairs(music_types) do
                    if imgui.Selectable(v, selected_music_type == k) then
                        selected_music_type = k
                    end
                end
                imgui.EndCombo()
            end
        end

        -- Song dropdown with integrated search
        if imgui.BeginCombo('Song', songs[selected_song] or 'Unknown') then
            -- Integrated search bar
            local search_ref = { dropdown_search_filter }
            if imgui.InputText('##Search', search_ref, 256) then
                dropdown_search_filter = search_ref[1]
            end

            -- Filter and display dropdown options
            for _, song_entry in ipairs(sorted_songs) do
                if dropdown_search_filter == ''
                    or song_entry.name:lower():find(dropdown_search_filter:lower(), 1, true)
                then
                    if imgui.Selectable(song_entry.name, selected_song == song_entry.id) then
                        selected_song = song_entry.id
                    end
                end
            end
            imgui.EndCombo()
        end

        -- Set Music button
        if imgui.Button('Set Music') then
            if apply_to_all then
                print(string.format("Set music: %s for all music types", songs[selected_song]))
                for music_type = 0, 7 do
                    SetMusicPacket(music_type, selected_song)
                end
            else
                print(string.format("Set music: %s for %s", songs[selected_song], music_types[selected_music_type]))
                SetMusicPacket(selected_music_type, selected_song)
            end
        end

    end
    -- Close the window
    imgui.End()

    -- ImGui sets is_open_ref[1] to false if user clicked "X"
    is_open = is_open_ref[1]

    PopBlueWhiteStyles()
end)

-- Command to toggle the menu
ashita.events.register('command', 'command_callback', function(e)
    local args = {};
    for word in string.gmatch(e.command, "[%S]+") do
        table.insert(args, word);
    end

    if args[1] ~= '/setbgm' then return; end
    is_open = not is_open;
    e.blocked = true;
end);