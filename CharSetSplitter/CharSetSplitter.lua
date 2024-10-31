--Auto Spilting for making bigger sprites into charsets made by openbreeze
--Based on scripts by OpsisKalopsis on github
--Dex was here also >:3

local doVSplits = true
local doHSplits = false
local doHideLayer = true
local doSplitVisible = false

function ToggleVSplits()
  doVSplits = not doVSplits
end

function ToggleHSplits()
  doHSplits = not doHSplits
end

function ToggleHideLayer()
  doHideLayer = not doHideLayer
end

function ToggleSplitVisible()
  doSplitVisible = not doSplitVisible
end

function CopyAndSplitImage(fromImage, spriteRect, splitRect, colorMode)
    local pixelsInRect = fromImage:pixels(splitRect)
    local newImage = Image(spriteRect.width, spriteRect.height, colorMode)
    local xOffset = 0
	local yOffset = 0
	local yStep = 0;
    --------------------------------
	-- variables affected by configs
	local _xStartOffset = 0
	local _yStartOffset = 0
	if doVSplits then
		_xStartOffset = 4
	end
	if doHSplits then
		_yStartOffset = 16
	end
	--------------------------------
    for it in pixelsInRect do
      local pixelValue = it()
      local newX = it.x - splitRect.x
      local newY = it.y - splitRect.y

	  if(doHSplits and newY ~= yStep and newY % 16 == 0) then
		yStep = newY
		yOffset = yOffset + 16
      end
	  
      if(doVSplits and newX ~= 0 and newX % 16 == 0) then
        xOffset = xOffset + 8
      end
	  
	  if(newX == 0) then
		xOffset = 0
	  end
	  
      newImage:putPixel(newX + xOffset + _xStartOffset, newY + yOffset + _yStartOffset, pixelValue)
    end
    return newImage
end

function RefreshCanvas()
  --should be a nicer solution
  app.command.Undo()
  app.command.Redo()
end

function SplitTheImage()
  ---------------------------------------------
  -- check that the sprite selection is valid
  local sprite = app.sprite
  if not sprite then 
  	print("No sprite")
  	return
  end
  ---------------------------------------------
  local selection = sprite.selection
  ---------------------------------------------
  local currentCel = app.cel
  local colorMode = sprite.colorMode
  
  local celBounds = app.cel.bounds
  local splitBounds
  if selection.isEmpty then
  	splitBounds = Rectangle(0, 0, celBounds.x + celBounds.width, celBounds.y + celBounds.height)
  else
  	splitBounds = selection.bounds
  end
  ---------------------------------------------
  
  local currentImage = Image(sprite.width, sprite.height, colorMode)
  if doSplitVisible then
	currentImage:drawSprite(sprite, currentCel.frameNumber)
  else
    currentImage:drawImage(currentCel.image)
  end
  local selectedImage = CopyAndSplitImage(currentImage, sprite.bounds, splitBounds, colorMode)
  
  app.transaction(
    function() 
	  if doHideLayer then
		app.layer.isVisible  = false
	  end
	  local layerName = app.layer.name
	  local outputLayer = sprite:newLayer()
	  outputLayer.name = layerName .. "_Splitted"
	  local outputSprite = outputLayer.sprite
	  local cel = sprite:newCel(outputLayer, currentCel.frameNumber)
	  local backToOriginImage = Image(outputSprite.width,outputSprite.height, colorMode)
	  backToOriginImage:drawImage(selectedImage)
	  cel.image = backToOriginImage
	end
  )
  RefreshCanvas()
end


local dialog = Dialog("CharSet Splitter")
dialog
  :check{id="vsplit", text="Vertical Splits", selected=true, onclick=ToggleVSplits}
  :newrow()
  :check{id="hsplit", text="Horizontal Splits", selected=false, onclick=ToggleHSplits}
  :separator()
  :check{id="splitvisible", text="Split All Visible Layers", selected=false, onclick=ToggleSplitVisible}
  :newrow()
  :check{id="hidelayer", text="Hide Current Layer", selected=true, onclick=ToggleHideLayer}
  :separator()
  :button{text="Do The Thing",onclick=SplitTheImage}
  :show{wait=false}