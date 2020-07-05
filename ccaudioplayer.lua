local tape = peripheral.find("tape_drive")
-- Audio functions

local function isTapeEnded()
  return tape.isEnd()
end

local function clearTape()
  tape.seek(-tape.getSize());
  tape.write(string.rep(string.char(0), tape.getSize()));
end

local function playAudio(fn)
  tape.seek(-tape.getSize())
  local fh = fs.open(fn, "rb")
  tape.write(fh.readAll())
  fh.close()
  tape.seek(-tape.getSize())
  tape.play()
end

local function getAudio()
  local fh = fs.open("disk/.audio", "r")
  local data = {}
  local s = fh.readLine()
  while s ~= "" and s do
    local audioName = s

    local audioAuthor = fh.readLine()
    if (audioAuthor == "") then
      audioAuthor = "Unknown"
    elseif audioAuthor == nil then
      return {}
    end

    local audioFile = fh.readLine()
    if (audioFile == "") or not audioFile then
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

local function lenTab(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local function getItem(T, i)
  local count = 0
  for _, v in pairs(T) do
    if count == i then
      return v
    end
    count = count + 1
  end
  return nil
end

local function drawList(data, selit, playit, pstate)
  term.setBackgroundColor(colors.black)
  term.setTextColor(colors.white)
  term.setCursorPos(1,1)
  term.clear()
  local i = 0
  for k, fn in pairs(data) do
    term.setBackgroundColor(colors.gray)
    term.setTextColor(colors.white)
    if (i == playit) and tape.getState() == "PLAYING" then
      term.setBackgroundColor(colors.green)
      term.setTextColor(colors.white)
    elseif (i == playit) and (tape.getState() == "STOPPED" or tape.getState() == "REWINDING" or tape.getState() == "FORWARDING") and not tape.isEnd() then
      term.setBackgroundColor(colors.red)
      term.setTextColor(colors.white)
    end
    if i == selit then
      term.setBackgroundColor(colors.orange)
      term.setTextColor(colors.white)
    end
    print(k)
    i = i + 1
  end
end

-- Showing all music files
local audio = getAudio()

local selectedItem = 0
local playingItem = -1
local playingState = false

local function draw()
  drawList(audio, selectedItem, playingItem, playingState)
end

draw()

local timer = os.startTimer(1)

while true do
  --drawList(audio, selectedItem, playingItem, playingState)
  local event, par = os.pullEventRaw()
  -- If app is terminated then stop music
  if event == "terminate" then
    term.setBackgroundColor(colors.black)
    term.setTextColor(colors.white)
    term.clear()
    term.setCursorPos(1,1)
    clearTape()
    break
  elseif event == "timer" then
    if par == timer then
      timer = os.startTimer(1)
      if isTapeEnded() then
        playingItem = -1
        playingState = false
      end
      draw()
    end
  end
  if event == "key" then
    if par == keys.up then
      if selectedItem > 0 then
        selectedItem = selectedItem - 1
      end
    elseif par == keys.down then
      if selectedItem < lenTab(audio) - 1 then
        selectedItem = selectedItem + 1
      end
    elseif par == keys.enter then
        if selectedItem == playingItem then
          if playingState == true then
            tape.stop()
            playingState = false
          else
            tape.play()
            playingState = true
          end
        else
          clearTape()
          playAudio("disk/"..getItem(audio, selectedItem))
          playingItem = selectedItem
          playingState = true
        end
      end
      draw()
  end
end
