--!strict
local Types = require("@self/Types")
local utils = require("@self/utils")

local toolbar = plugin:CreateToolbar("AudioTraverser")
local Selection = game:GetService("Selection")

local previewButton = toolbar:CreateButton(
	"AudioTraverserPreview",
	"Toggle preview mode",
	"rbxassetid://77467552837145",
	"Audio Preview"
)

previewButton.ClickableWhenViewportHidden = true

local PREVIEW_ACTIVE = false

local CONNECTION : RBXScriptConnection?

local function processSelection()
	utils.cleanupPreview()
	if not PREVIEW_ACTIVE then
		return
	end

	local newSelection : {Instance} = Selection:Get()

	if #newSelection ~= 1 then
		-- we probably shouldn't wire up multiple sounds to the output because the roblox previewer doesn't support it, for now in v26.01 we will only support studio previews.
		return
	end

	-- TODO v26.02: Support more new Audio Api types; so for example, you can select a filter, it will go back in the tree to figure what the inputs are, and then play it.
	local singleSelection : Instance | Types.AudioObject = newSelection[1]

	if singleSelection:IsA("AudioPlayer") then
		local current: Types.AudioObject =  utils.asAudioObject(singleSelection) :: Types.AudioObject
		local visited: {[Instance]: boolean} = {}
	
		while true do
			if visited[current] then
				warn("[AudioTraversal] Cycle detected.")
				break
			end
	
			visited[current] = true
	
			local nextObject, status = utils.traverseObject(current)
	
			if status == "Next" then
				if nextObject == nil then
					break
				end
	
				current = nextObject
			elseif status == "Unconnected" then
				utils.setupPreview(current)
				CONNECTION = current.ChildAdded:Connect(function() utils.setupPreview(current) end)
				print("[AudioTraversal] Preview is ready to go!")
				break
			elseif status == "Output" then
				-- Already reaches a device output.
				break
			elseif status == "Branch" then
				warn("[AudioTraversal] Multiple connections; preview skipped.")
				break
			else
				warn("[AudioTraversal] Unsupported or incomplete path.")
				break
			end
		end
	end
end

Selection.SelectionChanged:Connect(processSelection)

previewButton.Click:Connect(function()
	PREVIEW_ACTIVE = not PREVIEW_ACTIVE
	previewButton.IconContent = if PREVIEW_ACTIVE then Content.fromAssetId(82678461168456) else Content.fromAssetId(77467552837145)

	if not PREVIEW_ACTIVE then utils.cleanupPreview() else processSelection() end
end)