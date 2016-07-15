import Speech

struct Listener {
    let language: Language
    private let recognizer: SFSpeechRecognizer?
    private let audioEngine = AVAudioEngine()

    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?

    private var listening = false


    private var speaker = Speaker(language: .portuguese)

    init(language: Language) {
        self.language = language
        recognizer = SFSpeechRecognizer(locale: language.locale)
    }

    mutating func startListening() {
        guard !listening else { return }
        listening = true

        guard (try? configureAudioSession()) != .none else { return }

        guard let inputNode = audioEngine.inputNode else {
            fatalError("Audio engine has no input node")
            //TODO: Fail gracefully
        }

        let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        recognitionRequest.shouldReportPartialResults = true

        self.recognitionRequest = recognitionRequest

        recognitionTask = recognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            print("Result: \(result)")

            guard let oi = Regex(pattern: "oi", options: [.caseInsensitive]),
            let tudoBem = Regex(pattern: "tudo (?:bem)?\\s*e?\\s*(você)?", options: [.caseInsensitive]),
                let bestResult = result?.bestTranscription.formattedString else {
                    return
            }

            if oi.match(string: bestResult) {
                self.speak(sentence: "Olá! Tudo bem com você?")
            } else if tudoBem.match(string: bestResult) {
                let captures = tudoBem.matches(string: bestResult).first?.captureGroups
                if captures?.count > 0 {
                    self.speak(sentence: "Tudo ótimo, obrigdo por perguntar!")
                } else {
                    self.speak(sentence: "Que bom!")
                }
            }
        })

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) {
            self.recognitionRequest?.append($0.0)
        }

        audioEngine.prepare()
        let _ = try? audioEngine.start()
    }

    private func configureAudioSession() throws -> AVAudioSession {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(AVAudioSessionCategoryRecord)
        try audioSession.setMode(AVAudioSessionModeMeasurement)
        try audioSession.setActive(true, with: .notifyOthersOnDeactivation)

        return audioSession
    }

    mutating func stopListening() {
        guard listening else { return }
        listening = false

        audioEngine.stop()
        recognitionRequest?.endAudio()
    }

    mutating func speak(sentence: String) {
        stopListening()
        speaker.speak(sentence: sentence)
    }
}
