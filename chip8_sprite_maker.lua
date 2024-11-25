-- take user input
local dialog = Dialog()
    :file { id = "spritefile", label = "Save Sprite File At", save = true, focus = true }
    :entry { id = "name", label = "Sprite Name" }
    :combobox { id = "padding", label = "Padding Side", option = "right", options = { "right", "left" } }
    :button { id = "ok", text = "Ok" }
    :button { id = "cancel", text = "Cancel" }
    :show()

if dialog.data["cancel"] then
    return
end
if dialog.data["spritefile"] == "" then
    Dialog():label { label = "Error: You must select a valid save file location." }:show()
    return
end
local savefile = dialog.data["spritefile"]
local paddingSide = dialog.data["padding"]
local spriteName = dialog.data["name"]

-- grab selection
local spr = app.sprite
if not spr then
    Dialog():label { label = "Error: No sprite found." }:show()
    return
end

local sel = spr.selection
if sel.isEmpty then return end

-- grab image from active layer
local layer = app.layer
if not #layer.cels == 1 then
    Dialog():label { label = "Error: Too many or too few images on active layer." }:show()
    return
end
local img = layer.cels[1]

-- the intersection of the selection and the image
local pixelRect = sel.bounds:intersect(img.bounds)
if pixelRect.isEmpty then
    Dialog():label { label = "Error: Could not find any pixels in selection on active layer." }:show()
    return
end

local output = ""

-- loop through pixels and read their data
local xStart = pixelRect.x - img.bounds.x
local xStop = xStart + pixelRect.width - 1
local yStart = pixelRect.y - img.bounds.y
local yStop = pixelRect.y + pixelRect.height - 1

local curIndex
if paddingSide == "right" then
    curIndex = xStart
else
    local offset = 8 - (pixelRect.width % 8)
    curIndex = xStart - offset
end


local spriteNum = 1
while curIndex <= xStop do
    output = output .. "sprite " .. spriteName .. spriteNum .. "\n"
    for y = yStart, yStop do
        output = output .. "\t0b"
        for x = curIndex, curIndex + 8 - 1 do
            if x > xStop or x < xStart then
                output = output .. "0"
            else
                local pixelData = img.image:getPixel(x, y)
                if pixelData == 0 then
                    output = output .. "0"
                else
                    output = output .. "1"
                end
            end
        end
        output = output .. "\n"
    end
    output = output .. "endsprite\n"
    spriteNum = spriteNum + 1
    curIndex = curIndex + 8
end

local file = io.open(savefile, "a")
io.output(file)
io.write(output)
io.close()

Dialog():label { label = "Successfully wrote sprite data to " .. savefile }:button { text = "Ok" }:show()

return
