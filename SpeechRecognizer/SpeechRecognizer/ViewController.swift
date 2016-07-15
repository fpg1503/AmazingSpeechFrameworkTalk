import UIKit

class ViewController: UIViewController {

    private var listener: Listener?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        listener = Listener(language: .portuguese)

        listener?.startListening()
    }
}

