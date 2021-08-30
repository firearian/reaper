--[[
 * ReaScript Name: Copy SFX from one Project to Another by comparing Track Names.
 * Description: A way to copy the effects chain from all the tracks of one project to another project with the same track names.
 * Author: firearian
 * Author URI: N/A
 * Repository: GitHub > firearian > reaper
 * Repository URI: https://github.com/firearian/reaper
 * Licence: GPL v3
 * REAPER: 6.32
 * Version: 1.0
--]]


function getProjectIDs()
  current_project, projfn = reaper.EnumProjects( -1 )
  current_track_count = reaper.CountTracks( current_project )
  reaper.ShowConsoleMsg("New Count: " .. tostring(current_track_count) .. "\n")
  old_project, projfn = reaper.EnumProjects( 1 )
  old_track_count = reaper.CountTracks( old_project )
  reaper.ShowConsoleMsg("Old Count: " .. tostring(old_track_count) .. "\n")
end

function run_command(command)
  command = reaper.NamedCommandLookup(command)
  reaper.Main_OnCommand( command,0 )
end

function create_track_tables(prj, track_count)
  for i = 0,track_count-1 do
    track = reaper.GetTrack( track_count, i )
    retval, track_name = reaper.GetTrackName( track )
    if (prj == "old") then
      old_names[track_name] = track
    else
      current_names[i] = {}
      current_names[i][1] = track_name
      current_names[i][2] = track
    end
  end
end

-- init. Script starts from here --
-- Get the project IDs for the current project and the next project --
-- Deselect all tracks from both projects --

getProjectIDs()
run_command(40297)
reaper.SelectProjectInstance( old_project )
run_command(40297)
reaper.SelectProjectInstance( current_project )

-- Create tables of tracks in both projects --

current_names = {}
old_names = {}

create_track_tables("new", current_track_count)
reaper.SelectProjectInstance( old_project )
create_track_tables("old", current_track_count)

-- The actual copy-pasting of the effects chain --

for i = 0,#current_names do
  reaper.ShowConsoleMsg("Track Name: " .. current_names[i][1] .. "\n")
  if (old_names[current_names[i][1]]) then
    reaper.ShowConsoleMsg("Found track " .. current_names[i][1] .. " in old project. \n")
    reaper.SetTrackSelected( old_names[current_names[i][1]], true )
    reaper.ShowConsoleMsg("Copying FX \n")
    run_command("_S&M_COPYFXCHAIN5")
    run_command(40297)

    reaper.SelectProjectInstance( current_project )
    reaper.SetTrackSelected( current_names[i][2], true )
    reaper.ShowConsoleMsg("Pasting FX \n")
    run_command("_S&M_COPYFXCHAIN10")
    reaper.ShowConsoleMsg("Track " .. current_names[i][1] .. " FX copied. \n")
  else
    reaper.ShowConsoleMsg("Did not find track " .. current_names[i][1] .. " in old project. \n")
  end
  run_command(40297)
  reaper.SelectProjectInstance( old_project )
  reaper.ShowConsoleMsg("--------------------------------------- \n")
end

reaper.SelectProjectInstance( current_project )
reaper.ShowConsoleMsg("FX Copying Ended. \n")

