os.pullEvent = os.pullEventRaw

-- Audio functions
function findTape()
  local tape = peripheral.wrap("left")
  if not(tape == nil) then
    if not(tape.play == nil) then
      return tape
    end
  end
  tape = peripheral.wrap("right")
  if not(tape == nil) then
    if not(tape.play == nil) then
      return tape
    end
  end
  tape = peripheral.wrap("up")
  if not(tape == nil) then
    if not(tape.play == nil) then
      return tape
    end
  end
  tape = peripheral.wrap("down")
  if not(tape == nil) then
    if not(tape.play == nil) then
      return tape
    end
  end
  tape = peripheral.wrap("front")
  if not(tape == nil) then
    if not(tape.play == nil) then
      return tape
    end
  end
  tape = peripheral.wrap("back")
  if not(tape == nil) then
    if not(tape.play == nil) then
      return tape
    end
  end
  return nil
end

function clearTape()
  local tape = findTape()
  tape.seek(-tape.getSize());
  tape.write(string.rep(string.char(0), tape.getSize()));
end

function playAudio(fn)
  local tape = findTape()
  tape.seek(-tape.getSize())
  local fh = fs.open(fn, "rb")
  tape.write(fh.readAll())
  fh.close()
  tape.seek(-tape.getSize())
  tape.play()
end

function getAudio()
  local fh = fs.open("disk/.audio", "r")
  local data = {}
  local s = fh.readLine()
  while not (s == "") and not (s == nil) do
    local audioName = s

    local audioAuthor = fh.readLine()
    if (audioAuthor == "") then
      audioAuthor = "Unknown"
    elseif audioAuthor == nil then
      return {}
    end

    local audioFile = fh.readLine()
    if (audioFile == "") or (audioFile == nil) then
      return {}
    end

    -- Adding audio file
    local label = audioName.." - "..audioAuthor
    local w, h = term.getSize()
    local i = string.len(label) % w
    while i < w do
      label = label.." "
      i = i + 1
    end
    data[label] = audioFile
    s = fh.readLine()
  end
  fh.close()
  return data
end

function lenTab(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function getItem(T, i)
  local count = 0
  for _, v in pairs(T) do
    if count == i then
      return v
    end
    count = count + 1
  end
  return nil
end

function drawList(data, selit)
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.setCursorPos(1,1)
  term.clear()
  local i = 0
  for k, fn in pairs(data) do
    if i == selit then
      term.setBackgroundColor(colors.orange)
      term.setTextColor(colors.white)
    else
      term.setBackgroundColor(colors.gray)
      term.setTextColor(colors.white)
    end
    print(k)
    i = i + 1
  end
end

-- Showing all music files
local audio = getAudio()

local selectedItem = 0
while true do
  drawList(audio, selectedItem)
  local event, key = os.pullEvent( "key" )
  -- If app is terminated then stop music
  if event == "terminate" then
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1,1)
    clearTape()
    break
  end
  if key == keys.up then
    if selectedItem > 0 then
      selectedItem = selectedItem - 1
    end
  elseif key == keys.down then
    if selectedItem < lenTab(audio) - 1 then
      selectedItem = selectedItem + 1
    end
  elseif key == keys.enter then
      clearTape()
      playAudio("disk/"..getItem(audio, selectedItem))
  end
end
