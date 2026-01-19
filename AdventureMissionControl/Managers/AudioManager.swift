import AVFoundation
import AudioToolbox
import SwiftUI

@Observable
class AudioManager {
    // MARK: - Volume Constants
    private let musicVolumeMultiplier: Float = 0.6
    private let ambientVolumeMultiplier: Float = 0.4

    private var musicPlayer: AVAudioPlayer?
    private var ambientPlayer: AVAudioPlayer?
    private var effectPlayers: [AVAudioPlayer] = []

    var volume: Float = 0.7 {
        didSet {
            updateAllVolumes()
        }
    }

    var isMuted: Bool = false {
        didSet {
            updateAllVolumes()
        }
    }

    private var effectiveVolume: Float {
        isMuted ? 0 : volume
    }

    private func updateAllVolumes() {
        musicPlayer?.volume = effectiveVolume * musicVolumeMultiplier
        ambientPlayer?.volume = effectiveVolume * ambientVolumeMultiplier
    }

    var isPlaying: Bool {
        musicPlayer?.isPlaying ?? false || ambientPlayer?.isPlaying ?? false
    }

    init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Music

    func playMusic(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Music file not found: \(name)")
            // Play placeholder tone for development
            playPlaceholderTone(for: .music)
            return
        }

        do {
            musicPlayer = try AVAudioPlayer(contentsOf: url)
            musicPlayer?.numberOfLoops = -1 // Loop indefinitely
            musicPlayer?.volume = effectiveVolume * musicVolumeMultiplier
            musicPlayer?.play()
        } catch {
            print("Failed to play music: \(error)")
        }
    }

    func stopMusic() {
        musicPlayer?.stop()
        musicPlayer = nil
    }

    // MARK: - Ambient

    func playAmbient(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Ambient file not found: \(name)")
            return
        }

        do {
            ambientPlayer = try AVAudioPlayer(contentsOf: url)
            ambientPlayer?.numberOfLoops = -1
            ambientPlayer?.volume = effectiveVolume * ambientVolumeMultiplier
            ambientPlayer?.play()
        } catch {
            print("Failed to play ambient: \(error)")
        }
    }

    func stopAmbient() {
        ambientPlayer?.stop()
        ambientPlayer = nil
    }

    // MARK: - Sound Effects

    func playEffect(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Effect file not found: \(name)")
            // Play a system sound as placeholder
            playPlaceholderTone(for: .effect)
            return
        }

        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.volume = effectiveVolume
            player.play()

            // Keep reference and clean up when done
            effectPlayers.append(player)
            cleanupFinishedEffects()
        } catch {
            print("Failed to play effect: \(error)")
        }
    }

    private func cleanupFinishedEffects() {
        effectPlayers.removeAll { !$0.isPlaying }
    }

    // MARK: - Placeholder Sounds (for development)

    private enum PlaceholderType {
        case music, effect
    }

    private func playPlaceholderTone(for type: PlaceholderType) {
        // Use system sounds as placeholders during development
        switch type {
        case .music:
            // For music, we just log - no good system sound for this
            print("🎵 [Placeholder] Music would play here")
        case .effect:
            // Play a subtle system sound
            AudioServicesPlaySystemSound(1104) // Subtle click
        }
    }

    // MARK: - Theme Audio

    func playThemeAudio(for theme: Theme) {
        stopAll()
        playMusic(named: theme.musicSoundName)
        playAmbient(named: theme.ambientSoundName)
    }

    func stopAll() {
        stopMusic()
        stopAmbient()
        effectPlayers.forEach { $0.stop() }
        effectPlayers.removeAll()
    }
}

// MARK: - Suggested Free Sound Sources
/*
 For real audio files, here are some royalty-free sources:

 AMBIENT SOUNDS:
 - freesound.org - Search for "space ambient", "underwater", "city traffic", "western wind"
 - zapsplat.com - Good categorized ambient loops

 MUSIC:
 - incompetech.com - Kevin MacLeod's royalty-free music
 - freepd.com - Public domain music
 - Search for: "space synth loop", "ocean calm music", "city jazz", "western guitar"

 SOUND EFFECTS:
 - freesound.org - Excellent for specific effects
 - mixkit.co - Free sound effects
 - Search for theme-specific sounds like "laser", "splash", "car horn", "horse gallop"

 FILE FORMAT:
 - Use MP3 or M4A for music/ambient (smaller files)
 - Use WAV or CAF for short effects (lower latency)

 NAMING CONVENTION:
 - space_music.mp3, space_ambient.mp3, laser.mp3
 - ocean_music.mp3, ocean_ambient.mp3, splash.mp3
 - city_music.mp3, city_ambient.mp3, horn.mp3
 - western_music.mp3, western_ambient.mp3, gallop.mp3
 */
