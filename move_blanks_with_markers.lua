function addToArray (item_get, i)
  local start_pos = reaper.GetMediaItemInfo_Value(item_get,"D_POSITION");
  --reaper.ShowConsoleMsg("start pos: " .. start_pos .. "\n")
  local item_length = reaper.GetMediaItemInfo_Value(item_get,"D_LENGTH");
  --reaper.ShowConsoleMsg("length: " .. item_length .. "\n")
  local end_pos = start_pos + item_length;
  --reaper.ShowConsoleMsg("end pos: " .. end_pos .. "\n")
  item[i+1] = {}
  item[i+1][1] = start_pos;
  item[i+1][2] = end_pos;
  item[i+1][3] = i+1;
  item[i+1][4] = item_get;
  end

function init ()
  for i = 0, count_media_items -1 do
      item_get = reaper.GetMediaItem(0, i)
      addToArray(item_get, i)
  end
  table.sort(item, function (current_item, next_item)
      --reaper.ShowConsoleMsg(current_item[1] .. "<" .. next_item[1] .. "\n")
      --reaper.ShowConsoleMsg(tostring(current_item[1] < next_item[1]) .. "\n")
      return current_item[1] < next_item[1]
  end)
  
  for j = 1, #item do
    item[j][3] = j
    --reaper.ShowConsoleMsg(item[j][1] .. "\n")
   -- reaper.ShowConsoleMsg(item[j][1] .. "\n")
  end
  reaper.ShowConsoleMsg("-----------------------\n")
end

function getNextItem(current_item)
  local current_item_end = current_item[2]
  for k = 1, #item do
    --reaper.ShowConsoleMsg(item[k][2] .. "\n")
    --reaper.ShowConsoleMsg(item[k][1] .. "\n")
    --reaper.ShowConsoleMsg(current_item_end .. "\n")
    if item[k][2] > current_item_end and current_item_end >= item[k][1] then
      --reaper.ShowConsoleMsg("Entered 0.1\n")
      return {true, item[k]}
    elseif current_item_end < item[k][1] then
      --reaper.ShowConsoleMsg("Entered 0.2\n")
      local duration = item[k][1] - current_item_end
      return {false, item[k][3], duration, item[k][4]}
    else
      --reaper.ShowConsoleMsg("Entered 0.3\n")
    end
  end
  return {nil};
end


item = {};
item_ar_len = 1;
count_media_items = reaper.CountMediaItems(0);
init()
current_item = item[1]
xx = 0
while current_item ~= false do
  next_item = getNextItem(current_item)
  if (next_item[1]) then
    reaper.ShowConsoleMsg("Entered 1\n")
    current_item = next_item[2]
 elseif (type(next_item[1])== nil)then
    reaper.ShowConsoleMsg("Entered 2\n")
    current_item = false
  else
    reaper.ShowConsoleMsg("Entered 3\n")
    local l = next_item[2]
    if l == nil then
      return
    else
      while l < #item+1 do
        local diff = item[l][1] - next_item[3]
        reaper.SetMediaItemPosition(item[l][4], diff, true); 
        l = l+1
      end
      local markeridx, regionidx = reaper.GetLastMarkerAndCurRegion( 0, current_item[2])
      marker_index, num_markersOut, num_regionsOut = reaper.CountProjectMarkers( 0 )
      reaper.ShowConsoleMsg("m/markeridx" .. markeridx .. "\n")
      reaper.ShowConsoleMsg("marker_index" .. marker_index .. "\n")
      if markeridx == -1 then
      else
        local m = markeridx+1
        while m < marker_index do
          reaper.ShowConsoleMsg("Loop m" .. markeridx .. "\n")
          local retval, isrgn, pos, rgnend, name, markrgnindexnumber = reaper.EnumProjectMarkers(m)
          reaper.ShowConsoleMsg("pos" .. pos .. "\n")
          reaper.ShowConsoleMsg("next_item end" .. next_item[3] .. "\n")
          local diff = pos - next_item[3]
          reaper.ShowConsoleMsg("diff" .. diff .. "\n")
          reaper.SetProjectMarker( markrgnindexnumber, isrgn, diff, rgnend, name)
          m = m+1
        end
      end
      current_item = item[next_item[2]-1]
      init()
    end
  end
end


