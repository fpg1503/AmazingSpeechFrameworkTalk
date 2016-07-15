import AVFoundation

struct Speaker {
    let language: Language
    private let synthesizer = AVSpeechSynthesizer()
    private var voice: AVSpeechSynthesisVoice? {
        return AVSpeechSynthesisVoice(language: language.rawValue)
    }

    func speak(sentence: String) {
        let utterance = AVSpeechUtterance(string: sentence)
        utterance.voice = voice
        synthesizer.speak(utterance)
    }

}
