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
addon.version   = '1.2.10'
addon.desc      = [[/setbgm opens an ImGUI window to set music in loop or autoplay, sequentially or randomly.]]
addon.link    = 'https://github.com/Applesmmmmmmmm/SetBGM';

require('common');
local imgui = require('imgui');
local ffi = require('ffi');
local chat = require('chat');
local data = require('data');
local settingsMan = require('settings')
local packetManager = AshitaCore:GetPacketManager();

local songs_sorted = {};
for _, song in ipairs(data.songs_sorted_original) do
	if(not song.blacklisted) then 
		table.insert(songs_sorted, {id=song.id, name=song.name});
	end
end

local start_time = os.clock();

local auto_play_type_options = {loop="Loop", autoNext="AutoNext", autoShuffle="AutoShuffle"};
local imgui_auto_play_type_options = {{type=auto_play_type_options.loop}, {type=auto_play_type_options.autoNext}, {type=auto_play_type_options.autoShuffle}};

local is_playing = false;
local anti_spam = false;

local dropdown_search_filter = "";

local path = ('%sconfig\\addons\\%s\\'):fmt(AshitaCore:GetInstallPath(), addon.name)

local config = T{
    get     = nil,
    set     = nil,
};

local s = T{
};

local default_settings = T{
	current_song = 0,
	current_song_replacer = 0,
	current_song_ID = 0,
	overwrite_death_song = false,
	auto_play_type = auto_play_type_options.loop,	
	is_imgui_open = false,
	play_at_launch = false,	
	imgui_SFX_vol = T{100},
	imgui_BGM_vol = T{100};
};

ffi.cdef[[
    typedef int32_t (__cdecl* get_config_value_t)(int32_t);
    typedef int32_t (__cdecl* set_config_value_t)(int32_t, int32_t);
]];

local function GetVolumeSFX()
	if(not config.get) then
		print("Failed to get volume, get function invalid pointer");
		return;
	end	
	return tonumber(config.get(9));
end

local function GetVolumeBGM()
	if(not config.get) then
		print("Failed to get volume, get function invalid pointer");
		return;
	end	
	
	return tonumber(config.get(10));
end

--min:0, max:100, default:100
local function SetVolumeSFX(newVol)
	if(not config.set) then	print("Failed to set volume, set function invalid pointer"); return; end
	if(not newVol) then print("Failed to set volume, newVol nil"); return; end
	newVol = tonumber(newVol);
	config.set(9, math.clamp(newVol, 0, 100));
end

--min:0, max:100, default:100
local function SetVolumeBGM(newVol)
	if(not config.set) then	print("Failed to set volume, set function invalid pointer"); return; end
	if(not newVol) then print("Failed to set volume, newVol nil"); return; end
	newVol = tonumber(newVol);
	config.set(10, math.clamp(newVol, 0, 100));
end

ashita.events.register('load', 'load_cb', function ()
	s = settingsMan.load(default_settings);

    -- Obtain the needed function pointers..
    local ptr = ashita.memory.find('FFXiMain.dll', 0, '8B0D????????85C974??8B44240450E8????????C383C8FFC3', 0, 0);
    config.get = ffi.cast('get_config_value_t', ptr);
    config.set = ffi.cast('set_config_value_t', ashita.memory.find('FFXiMain.dll', 0, '85C974??8B4424088B5424045052E8????????C383C8FFC3', -6, 0));
	assert(config.get ~= nil, chat.header('config'):append(chat.error('Error: Failed to locate required \'get\' function pointer.')));
    assert(config.set ~= nil, chat.header('config'):append(chat.error('Error: Failed to locate required \'set\' function pointer.')));
	
	SetVolumeSFX(s.imgui_SFX_vol[1]);	
	SetVolumeBGM(s.imgui_BGM_vol[1]);	
	
end);

ashita.events.register('unload', 'unload_cb', function ()
	settingsMan.save();	
end);

local function SetAllMusic()
    if not data.song_ID_to_info[s.current_song_ID].name then print(string.format('\30\70Invalid songID: %s', string.format(s.current_song_ID))); end

    -- GP_SERV_COMMAND_MUSIC
    local op_code = 0x05F;
    local size = 0x08;
    local sync = 0x0000;	

	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 0, s.current_song_ID):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 1, s.current_song_ID):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 2, s.current_song_ID):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 3, s.current_song_ID):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 4, s.current_song_ID):totable());
	if (s.overwrite_death_song) then 
		packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 5, s.current_song_ID):totable());
	end	
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 6, s.current_song_ID):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 7, s.current_song_ID):totable());
end

local function SetAllMusicFake()
    -- GP_SERV_COMMAND_MUSIC
    local op_code = 0x05F;
    local size = 0x08;
    local sync = 0x0000;		
	local song_ID_fake = 0;

	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 0, song_ID_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 1, song_ID_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 2, song_ID_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 3, song_ID_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 4, song_ID_fake):totable());
	if (s.overwrite_death_song) then 
		packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 5, song_ID_fake):totable());
	end	
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 6, song_ID_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 7, song_ID_fake):totable());
end



local function DisplayHelp()
	print(string.format('\30\70SetBGM imgui window: /setbgm'));
end;

ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args();
    
    if (args[1]:lower() == "/setbgm") then
		s.is_imgui_open = not s.is_imgui_open;
        return true;
    else
        return false;
    end;
end);

local function NowPlayingDelayed()
	start_time = os.clock()
	SetAllMusic();
	anti_spam = false;
end

local function NowPlaying()
	if(s.current_song == 0 or anti_spam) then return; end
	s.current_song_ID = songs_sorted[s.current_song% (#songs_sorted+1)].id;
	s.current_song_replacer =s.current_song;
	anti_spam = true;	
	SetAllMusicFake();	
	NowPlayingDelayed:once(.9);
	local l = data.song_ID_to_info[s.current_song_ID].length_in_seconds		
	if(s.auto_play_type == auto_play_type_options.loop) then		
		print(chat.header('SetBGM') .. chat.colors.Lime..data.song_ID_to_info[s.current_song_ID].name ..' ('..s.auto_play_type..')'.. chat.colors.Reset);
	else
		print(chat.header('SetBGM') .. chat.colors.Lime..data.song_ID_to_info[s.current_song_ID].name.." {"..math.floor(l / 60).."m "..(l % 60).."s".."}"..' ('..s.auto_play_type..')'.. chat.colors.Reset);
	end
end

ashita.events.register('packet_in', 'packet_in_cb', function(e)
    if(e.id == 0x000A) then        		    		
		ashita.bits.pack_be(e.data_modified_raw, s.current_song_ID, 0x56, 0, 16);
		ashita.bits.pack_be(e.data_modified_raw, s.current_song_ID, 0x58, 0, 16);
        ashita.bits.pack_be(e.data_modified_raw, s.current_song_ID, 0x5A, 0, 16);
        ashita.bits.pack_be(e.data_modified_raw, s.current_song_ID, 0x5C, 0, 16);
		ashita.bits.pack_be(e.data_modified_raw, s.current_song_ID, 0x5E, 0, 16);		
		

		local moghouse = struct.unpack('b', e.data, 0x80 + 1)
        if moghouse == 1 then
			NowPlaying:once(.1);
        end
    end	
	-- if(e.id == 0x005F) then			
	-- end
	if(e.id == 0x0060) then
		ashita.bits.pack_be(e.data_modified_raw, 0, 0x04, 0, 16);
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

settingsMan.register('settings', 'settings_update', function(set)
    if (set ~= nil) then
        s = set;
    end
    settingsMan.save();
end);

ashita.events.register('d3d_present', 'present_cb', function ()	
	local timeDif = os.clock() - start_time;
	if(s.play_at_launch and not is_playing and (current_song and current_song > 0)) then		
		NowPlaying();
		is_playing = true;
	elseif(s.current_song ~= 0 and s.auto_play_type and timeDif >= data.song_ID_to_info[s.current_song_ID].length_in_seconds) then
		if(s.auto_play_type == auto_play_type_options.autoNext) then
			s.current_song = s.current_song + 1;						
			if s.current_song > #songs_sorted then s.current_song = 1; end		
			NowPlaying();
		elseif(s.auto_play_type == auto_play_type_options.autoShuffle) then
			--TODO: Better shuffling than this, so that we don't get repeat songs ever in a session.
			local count = 0;
			local count_max = 200;
			while(true) do
				local new_song_index = math.random(#songs_sorted);
				if (new_song_index ~= s.current_song) then 
					s.current_song = new_song_index;
					break;
				end
				if(count >= count_max) then break; end
				count = count + 1;
			end						
			NowPlaying();
		end			
	end

	if not s.is_imgui_open then				
        return;
    end

    PushBlueWhiteStyles();

    -- Window flags:
    -- ImGuiWindowFlags_AlwaysAutoResize => auto-resize to fit content
    -- ImGuiWindowFlags_NoCollapse       => hides the collapse arrow
    local windowFlags = bit.bor(ImGuiWindowFlags_AlwaysAutoResize, ImGuiWindowFlags_NoCollapse);	
    imgui.SetNextWindowSize({0, 0}, {1000, 1000});	
    local is_imgui_open_ref = { s.is_imgui_open };

    if imgui.Begin('Set Background Music', is_imgui_open_ref, windowFlags) then		        		
        if imgui.BeginCombo('Song', data.song_ID_to_info[s.current_song_ID] and data.song_ID_to_info[s.current_song_ID].name or '---------') then       
            local search_ref = { dropdown_search_filter }
            if imgui.InputText('##Search', search_ref, 256) then
                dropdown_search_filter = search_ref[1];
            end
            
            for i, song_entry in ipairs(songs_sorted) do
				local is_selected = (s.current_song_replacer == i)

                if dropdown_search_filter == '' or song_entry.name:lower():find(dropdown_search_filter:lower(), 1, true) then
                    if imgui.Selectable(song_entry.name, is_selected) then
                        s.current_song_ID = song_entry.id;
						s.current_song_replacer = i;
                    end
                end
				if is_selected then
                	imgui.SetItemDefaultFocus();
            	end
            end
            imgui.EndCombo();
			settingsMan.save();
        end

		
		if imgui.BeginCombo('Play Type', s.auto_play_type and s.auto_play_type or 'Unknown') then
			for i, option in ipairs(imgui_auto_play_type_options) do
				if imgui.Selectable(option.type, s.auto_play_type == option.type) then
					s.auto_play_type = option.type;
				end
			end			
			imgui.EndCombo();
			settingsMan.save();
		end						
				
        if imgui.Button('Play', {-1, 0}) then
			if(s.current_song_replacer and s.current_song_replacer >= 1) then
				s.current_song = (s.current_song_replacer >= 1 and s.current_song_replacer or s.current_song);
				NowPlaying();
			else
				print("SetBGM: Must choose song to play.");
			end
        end		

		if(imgui.SliderFloat('SFX Volume', s.imgui_SFX_vol, 0, 100, '%.0f', ImGuiSliderFlags_AlwaysClamp)) then 
			settingsMan.save();
			SetVolumeSFX(s.imgui_SFX_vol[1]);
		end
		
		
		if(imgui.SliderFloat('BGM Volume', s.imgui_BGM_vol, 0, 100, '%.0f', ImGuiSliderFlags_AlwaysClamp)) then 
			settingsMan.save();
			SetVolumeBGM(s.imgui_BGM_vol[1]);
		end
		

		if(imgui.Checkbox('Overwrite Death Music', {s.overwrite_death_song}))then
			s.overwrite_death_song = not s.overwrite_death_song;
			settingsMan.save();
		end

		if(imgui.Checkbox('Play at launch', {s.play_at_launch}))then
			s.play_at_launch = not s.play_at_launch;
			settingsMan.save();
		end
		
		if (s.auto_play_type ~= auto_play_type_options.loop and s.current_song ~= 0) then			
			imgui.SliderFloat('Song Progress %', {(os.clock()-start_time)/(data.song_ID_to_info[s.current_song_ID].length_in_seconds)*100}, 0, 100, '%.1f', ImGuiSliderFlags_NoInput);
		end
	end
	imgui.End();
    s.is_imgui_open = is_imgui_open_ref[1];

    PopBlueWhiteStyles();
end);