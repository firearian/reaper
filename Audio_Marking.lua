file = io.open("D:\\Coding\\AI_Vocal_Transcription\\Vosk\\vosk-api\\python\\example\\output.txt", "r")
io.input(file)
blue = reaper.ColorToNative(0,0,255)|0x1000000

for line in io.lines("D:\\Coding\\AI_Vocal_Transcription\\Vosk\\vosk-api\\python\\example\\output.txt") do
  reaper.ShowConsoleMsg(tonumber(line) .. "\n")
  marker_index, num_markersOut, num_regionsOut = reaper.CountProjectMarkers( 0 )
  reaper.AddProjectMarker2(0, 0, tonumber(line), 0, "Marker", marker_index+1, blue )
end
io.close(file)

