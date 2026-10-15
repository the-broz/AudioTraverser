--!strict
local Players = game:GetService("Players")
local ServerStorage = game:GetService("ServerStorage")

local Types = require("./Types")
type AudioObject = Types.AudioObject

local utils = {}
utils.Output = nil :: AudioDeviceOutput?
utils.OutputWire = nil :: Wire?

utils.AUDIO_CLASSES = {
	AudioPlayer = true,
	AudioDeviceInput = true,
	AudioDeviceOutput = true,
	AudioEmitter = true,
	AudioListener = true,
	AudioAnalyzer = true,
	AudioRecorder = true,
	AudioTextToSpeech = true,
	AudioSpeechToText = true,
	AudioChorus = true,
	AudioCompressor = true,
	AudioDistortion = true,
	AudioEcho = true,
	AudioEqualizer = true,
	AudioFader = true,
	AudioFilter = true,
	AudioFlanger = true,
	AudioGate = true,
	AudioLimiter = true,
	AudioPitchShifter = true,
	AudioReverb = true,
	AudioTremolo = true,
	AudioChannelMixer = true,
	AudioChannelSplitter = true,
	Wire = true,
} :: { [string]: boolean }

function utils.isTeamCreate() : boolean
	local players = Players:GetPlayers()

	return (#players > 0) -- in a local file, no players are added in Edit mode.
end

function utils.asAudioObject(object: Instance?): AudioObject?
	if not object then
		return nil
	end


    -- brutal
	if object:IsA("AudioPlayer")
		or object:IsA("AudioDeviceInput")
		or object:IsA("AudioDeviceOutput")
		or object:IsA("AudioEmitter")
		or object:IsA("AudioListener")
		or object:IsA("AudioAnalyzer")
		or object:IsA("AudioRecorder")
		or object:IsA("AudioTextToSpeech")
		or object:IsA("AudioSpeechToText")
		or object:IsA("AudioChorus")
		or object:IsA("AudioCompressor")
		or object:IsA("AudioDistortion")
		or object:IsA("AudioEcho")
		or object:IsA("AudioEqualizer")
		or object:IsA("AudioFader")
		or object:IsA("AudioFilter")
		or object:IsA("AudioFlanger")
		or object:IsA("AudioGate")
		or object:IsA("AudioLimiter")
		or object:IsA("AudioPitchShifter")
		or object:IsA("AudioReverb")
		or object:IsA("AudioTremolo")
		or object:IsA("AudioChannelMixer")
		or object:IsA("AudioChannelSplitter")
	then
		return object
	end

	return nil
end


function utils.traverseObject(object: Types.AudioObject): (Types.AudioObject?, Types.TraversalStatus)
	if object:IsA("AudioDeviceOutput") then
		return object, "Output"
	end

	if object:IsA("Wire") then
		return nil, "Invalid"
	end

	-- only one output allowed
	local outputPins: {string} = (object :: any):GetOutputPins()

	if #outputPins ~= 1 or outputPins[1] ~= "Output" then
		return nil, "Invalid"
	end

	local wires: {Wire} =
		(object :: any):GetConnectedWires("Output") :: {Wire}

	if #wires == 0 then
		-- attachable point
		return object, "Unconnected"
	end

	if #wires > 1 then
		return object, "Branch"
	end

	local wire = wires[1]
	local nextAudioObject = utils.asAudioObject(wire.TargetInstance)

	if not nextAudioObject or nextAudioObject:IsA("Wire") then
		return nil, "Invalid"
	end

	return nextAudioObject, "Next"
end

local function createOutput() : AudioDeviceOutput
	local output = Instance.new("AudioDeviceOutput")
	output.Parent = ServerStorage
	output.Name = "AudioTraversal_PreviewOutput"
	
	if utils.isTeamCreate() then
		output.Player = Players.LocalPlayer
	end

	local wire = Instance.new("Wire")
	wire.Parent = output
	wire.Name = "PreviewWire"
	wire.TargetInstance = output

	return output
end

function utils.setupPreview(finalObject : Types.AudioObject)
	local AudioOutput : AudioDeviceOutput = (ServerStorage:FindFirstChild("AudioTraversal_PreviewOutput") :: AudioDeviceOutput?) or createOutput()

	local wire : Wire? = AudioOutput:FindFirstChild("PreviewWire") :: Wire?

	if wire then
		utils.Output = AudioOutput
		utils.OutputWire = wire
		wire.SourceInstance = finalObject
	else
		AudioOutput:Destroy()
		utils.setupPreview(finalObject)
	end
end

function utils.cleanupPreview()
	if utils.OutputWire then
		(utils.OutputWire :: any).SourceInstance = nil
	end
end

return utils