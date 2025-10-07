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
addon.version   = '1.2.6'
addon.desc      = [[/setbgm opens an ImGUI window to set music in loop or autoplay, sequentially or randomly.]]
addon.link    = 'https://github.com/Applesmmmmmmmm/SetBGM';

require('common');
local imgui = require('imgui');
local packetManager = AshitaCore:GetPacketManager();
local ffi = require('ffi');
local chat = require('chat');
local data = require('data')

local songs_sorted = {};
for _, song in ipairs(data.songs_sorted_original) do
	if(not song.blacklisted) then 
		table.insert(songs_sorted, {id=song.id, name=song.name})
	end
end

local is_imgui_open = false;
local current_song = 0
local current_song_replacer = 0;
local start_time = os.clock()
local currentSongID = 0
local overwriteDeathSong = false;

local autoPlayTypeOptions = {loop="Loop", autoNext="AutoNext", autoShuffle="AutoShuffle"}
local imguiAutoPlayTypeOptions = {{type=autoPlayTypeOptions.loop}, {type=autoPlayTypeOptions.autoNext}, {type=autoPlayTypeOptions.autoShuffle}}
local autoPlayType = autoPlayTypeOptions.loop

local imgui_SFX_vol = {100};
local imgui_BGM_vol = {100};

local dropdown_search_filter = "";


local config = T{
    get     = nil,
    set     = nil,
};

ffi.cdef[[
    typedef int32_t (__cdecl* get_config_value_t)(int32_t);
    typedef int32_t (__cdecl* set_config_value_t)(int32_t, int32_t);
]];

local function get_volume_sfx()
	if(not config.get) then
		print("Failed to get volume, get function invalid pointer");
		return;
	end	
	return tonumber(config.get(9))
end

local function get_volume_bgm()
	if(not config.get) then
		print("Failed to get volume, get function invalid pointer");
		return;
	end	
	
	return tonumber(config.get(10))
end

ashita.events.register('load', 'load_cb', function ()
    -- Obtain the needed function pointers..
    local ptr = ashita.memory.find('FFXiMain.dll', 0, '8B0D????????85C974??8B44240450E8????????C383C8FFC3', 0, 0);
    config.get = ffi.cast('get_config_value_t', ptr);
    config.set = ffi.cast('set_config_value_t', ashita.memory.find('FFXiMain.dll', 0, '85C974??8B4424088B5424045052E8????????C383C8FFC3', -6, 0));
	assert(config.get ~= nil, chat.header('config'):append(chat.error('Error: Failed to locate required \'get\' function pointer.')));
    assert(config.set ~= nil, chat.header('config'):append(chat.error('Error: Failed to locate required \'set\' function pointer.')));

	imgui_SFX_vol[1] = get_volume_sfx();
	imgui_BGM_vol[1] = get_volume_bgm();	
end);

local function set_all_music()
	local song_id = currentSongID
	if not song_id then return end
	song_id = tonumber(song_id);
    if not data.song_id_to_info[song_id].name then print(string.format('\30\70Invalid song_id: %s', string.format(song_id))); end;

    -- GP_SERV_COMMAND_MUSIC
    local op_code = 0x05F;
    local size = 0x08;
    local sync = 0x0000;	

	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 0, song_id_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 1, song_id_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 2, song_id_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 3, song_id_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 4, song_id_fake):totable());
	if (overwriteDeathSong) then 
		packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 5, song_id_fake):totable());
	end	
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 6, song_id_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 7, song_id_fake):totable());

	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 0, song_id):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 1, song_id):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 2, song_id):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 3, song_id):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 4, song_id):totable());
	if (overwriteDeathSong) then 
		packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 5, song_id):totable());
	end	
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 6, song_id):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 7, song_id):totable());
end

local function set_all_music_fake()
    -- GP_SERV_COMMAND_MUSIC
    local op_code = 0x05F;
    local size = 0x08;
    local sync = 0x0000;		

	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 0, song_id_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 1, song_id_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 2, song_id_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 3, song_id_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 4, song_id_fake):totable());
	if (overwriteDeathSong) then 
		packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 5, song_id_fake):totable());
	end	
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 6, song_id_fake):totable());
	packetManager:AddIncomingPacket(op_code, struct.pack('BBHHH', op_code, size, sync, 7, song_id_fake):totable());

	
end

--min:0, max:100, default:100
local function set_volume_SFX(newVol)
	if(not config.set) then
		print("Failed to set volume, set function invalid pointer")
		return
	end
	if(not newVol) then 
		print("Failed to set volume, newVol nil")
		return
	end
	newVol = tonumber(newVol)	
	config.set(9, math.clamp(newVol, 0, 100))
end

--min:0, max:100, default:100
local function set_volume_BGM(newVol)
	if(not config.set) then
		print("Failed to set volume, set function invalid pointer")
		return
	end
	if(not newVol) then 
		print("Failed to set volume, newVol nil")
		return
	end
	newVol = tonumber(newVol)
	config.set(10, math.clamp(newVol, 0, 100))
end

local function display_help()
	print(string.format('\30\70SetBGM imgui window: /setbgm'))
end;

ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:args();
    
    if (args[1]:lower() == "/setbgm") then
		is_imgui_open = not is_imgui_open;
        return true;
    else
        return false;
    end;
end);

local function NowPlayingDelayed()
	start_time = os.clock()
	set_all_music()	
	local l = data.song_id_to_info[currentSongID].length_in_seconds		
	if(autoPlayType == autoPlayTypeOptions.loop) then
		print(chat.header('SetBGM') .. chat.colors.Lime..data.song_id_to_info[currentSongID].name ..' ('..autoPlayType..')'.. chat.colors.Reset);
	else
		print(chat.header('SetBGM') .. chat.colors.Lime..data.song_id_to_info[currentSongID].name.." {"..math.floor(l / 60).."m "..(l % 60).."s".."}"..' ('..autoPlayType..')'.. chat.colors.Reset);
	end
end

local function NowPlaying()	
	set_all_music_fake();
	NowPlayingDelayed:once(.9);
end

ashita.events.register('packet_in', 'packet_in_cb', function(e)
    if(e.id == 0x000A) then        		    		
		ashita.bits.pack_be(e.data_modified_raw, currentSongID, 0x56, 0, 16);
		ashita.bits.pack_be(e.data_modified_raw, currentSongID, 0x58, 0, 16);
        ashita.bits.pack_be(e.data_modified_raw, currentSongID, 0x5A, 0, 16);
        ashita.bits.pack_be(e.data_modified_raw, currentSongID, 0x5C, 0, 16);
		ashita.bits.pack_be(e.data_modified_raw, currentSongID, 0x5E, 0, 16);		
		

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

ashita.events.register('d3d_present', 'present_cb', function ()		
	local timeDif = os.clock() - start_time;
	if(current_song ~= 0 and autoPlayType and timeDif >= data.song_id_to_info[currentSongID].length_in_seconds) then
		if(autoPlayType == autoPlayTypeOptions.autoNext) then
			current_song = current_song + 1;
			currentSongID = songs_sorted[current_song% (#songs_sorted+1)].id;
			
			if current_song > #songs_sorted then current_song = 1 end		
			NowPlaying();
		elseif(autoPlayType == autoPlayTypeOptions.autoShuffle) then
			--TODO: Better shuffling than this, so that we don't get repeat songs ever in a session.
			local count = 0
			local count_max = 200
			while(true) do
				local new_song_index = math.random(#songs_sorted)
				if (new_song_index ~= current_song) then 
					current_song = new_song_index
					break
				end
				if(count >= count_max) then break end
				count = count + 1
			end
			currentSongID = songs_sorted[current_song].id;		
			NowPlaying();			
		end			
	end

	if not is_imgui_open then				
        return
    end

    PushBlueWhiteStyles()

    -- Window flags:
    -- ImGuiWindowFlags_AlwaysAutoResize => auto-resize to fit content
    -- ImGuiWindowFlags_NoCollapse       => hides the collapse arrow
    local windowFlags = bit.bor(ImGuiWindowFlags_AlwaysAutoResize, ImGuiWindowFlags_NoCollapse)
	
    imgui.SetNextWindowSize({0, 0}, {1000, 1000})
	
    local is_imgui_open_ref = { is_imgui_open }
		
    if imgui.Begin('Set Background Music', is_imgui_open_ref, windowFlags) then		        
        if imgui.BeginCombo('Song', data.song_id_to_info[currentSongID] and data.song_id_to_info[currentSongID].name or '---------') then            
            local search_ref = { dropdown_search_filter }
            if imgui.InputText('##Search', search_ref, 256) then
                dropdown_search_filter = search_ref[1]
            end
            
            for i, song_entry in ipairs(songs_sorted) do
				local is_selected = (current_song_replacer == i)

                if dropdown_search_filter == ''
                    or song_entry.name:lower():find(dropdown_search_filter:lower(), 1, true)
                then
                    if imgui.Selectable(song_entry.name, is_selected) then					
                        currentSongID = song_entry.id
						current_song_replacer = i
                    end
                end
				if is_selected then
                	imgui.SetItemDefaultFocus()
            	end
            end
            imgui.EndCombo()
        end

		if imgui.BeginCombo('Autoplay Type', autoPlayType or 'Unknown') then
			for i, option in ipairs(imguiAutoPlayTypeOptions) do
				if imgui.Selectable(option.type, autoPlayType == option.type) then
					autoPlayType = option.type					
				end
			end
			imgui.EndCombo()
		end			

		if(imgui.Checkbox('Overwrite Death Music', {overwriteDeathSong}))then
			overwriteDeathSong = not overwriteDeathSong
		end

		imgui.SameLine();						
				
        if imgui.Button('Play') then
			if(current_song_replacer and current_song_replacer >= 1) then
				current_song = (current_song_replacer >= 1 and current_song_replacer or current_song)				
				NowPlaying();
			else
				print("SetBGM: Must choose song to play.")
			end			
        end		
		
		imgui.SliderFloat('SFX Volume', imgui_SFX_vol, 0, 100, '%.0f', ImGuiSliderFlags_AlwaysClamp);
		set_volume_SFX(imgui_SFX_vol[1]);		
		imgui.SliderFloat('BGM Volume', imgui_BGM_vol, 0, 100, '%.0f', ImGuiSliderFlags_AlwaysClamp);
		set_volume_BGM(imgui_BGM_vol[1]);
		
		if (autoPlayType ~= autoPlayTypeOptions.loop and current_song ~= 0) then			
			imgui.SliderFloat('Song Progress %', {(os.clock()-start_time)/(data.song_id_to_info[currentSongID].length_in_seconds)*100}, 0, 100, '%.1f', ImGuiSliderFlags_NoInput);
		end
	end
	imgui.End()	
    is_imgui_open = is_imgui_open_ref[1]

    PopBlueWhiteStyles()
end);