--!strict

export type AudioObject =
	AudioPlayer
	| AudioDeviceInput
	| AudioDeviceOutput
	| AudioEmitter
	| AudioListener
	| AudioAnalyzer
	| AudioRecorder
	| AudioTextToSpeech
	| AudioSpeechToText
	| AudioChorus
	| AudioCompressor
	| AudioDistortion
	| AudioEcho
	| AudioEqualizer
	| AudioFader
	| AudioFilter
	| AudioFlanger
	| AudioGate
	| AudioLimiter
	| AudioPitchShifter
	| AudioReverb
	| AudioTremolo
	| AudioChannelMixer
	| AudioChannelSplitter

export type TraversalStatus =
	"Next"
	| "Unconnected"
	| "Output"
	| "Branch"
	| "Invalid"

return {}