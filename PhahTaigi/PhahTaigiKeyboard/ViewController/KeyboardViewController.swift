
import UIKit
import Haptica

class KeyboardViewController: UIInputViewController {
    
    // custom height for keyboard
    var keyboardHeightConstraint:NSLayoutConstraint? = nil
    
    // view
    var keyboardView: KeyboardView?
    
    // keyboard status
    var currentPageIndex: PageIndex = PageIndex.taigi {
        didSet {
            self.keyboardView!.typingView!.selectPage(selectedPageIndex: self.currentPageIndex)
        }
    }
    
    // typing text
    var typingText: String = "" {
        didSet {
            // update view
            self.keyboardView?.selectionView?.inputDisplayView?.text = self.typingText
            
            if self.typingText.isEmpty {
                self.showMenu()
            } else {
                self.hideMenu()
            }
        }
    }
    var keyLongPressBackspaceTimer: Timer?
    
    // input handle
    var taigiInputProcessor: TaigiInputProcessor?
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        print("initNib")
        
        // init
        SettingView.registerDefaultSettings()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("viewDidLoad")
        
//        print("screen w=\(UIScreen.main.bounds.width), h=\(UIScreen.main.bounds.height)")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("viewWillLayoutSubviews")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("viewDidLayoutSubviews")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear")
        print("system keyboardView w=\(self.view.frame.width), h=\(self.view.frame.height)")
        
        self.view.backgroundColor = UIColor.clear
        self.inputView!.backgroundColor = UIColor.clear
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("viewDidAppear")
        
        self.updateKeyboardHeightConstraint()
        self.setKeyboardView()
        self.checkAutoCapitalize()
    }
    
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        print("willTransition")
        
        // TODO: different size, direction
    }

    override func updateViewConstraints() {
        super.updateViewConstraints()
        print("updateViewConstraints")
        
        self.updateKeyboardHeightConstraint()
    }
    
    func updateKeyboardHeightConstraint() {
        if self.view.frame.size.width == 0 && self.view.frame.size.height == 0 {
            return
        }
        
        guard self.keyboardHeightConstraint != nil else {
            self.inputView!.allowsSelfSizing = true
            
            // We must add a subview with an `instrinsicContentSize` that uses autolayout to force the height constraint to be recognized.
            let emptyView = UILabel(frame: CGRect(x: 1, y: 1, width: 1, height: 1))
            emptyView.translatesAutoresizingMaskIntoConstraints = false
            emptyView.backgroundColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0)
            self.view.addSubview(emptyView)
            
            // init
            self.keyboardHeightConstraint = NSLayoutConstraint(item: self.view,
                                                               attribute: .height,
                                                               relatedBy: .equal,
                                                               toItem: nil,
                                                               attribute: .notAnAttribute,
                                                               multiplier: 0,
                                                               constant: KeyboardViewConstant.keyboardHeight)
            self.keyboardHeightConstraint!.priority = UILayoutPriority(rawValue: 999)
            self.keyboardHeightConstraint!.isActive = true
            
            self.view.addConstraint(self.keyboardHeightConstraint!)
            
            return
        }
            
        self.keyboardHeightConstraint?.constant = KeyboardViewConstant.keyboardHeight
    }
    
    func setKeyboardView() {
        if (self.keyboardView == nil) {
            self.keyboardView = KeyboardViewLayout.build()
            self.view.addSubview(self.keyboardView!)
            
            self.taigiInputProcessor = TaigiInputProcessor(keyboardView: self.keyboardView!)
            
            addKeyListener()
            
            // callback: handle charactor key up
            self.keyboardView!.typingView!.onKeyUpCharactor = { charText in
                switch self.keyboardView!.typingView!.currentPageIndex {
                case .taigi:
                    if charText.isNumber {
                        if self.hasTypingText() {
                            self.appendTypingText(text: charText)
                        } else {
                            self.sendTypingTextAndKey(keyText: charText)
                        }
                    } else if (KeyboardTemplate.taigiLomajiDirectOutputKey.contains(charText)) {
                        self.sendTypingTextAndKey(keyText: charText)
                    } else {
                        self.appendTypingText(text: charText)
                    }

                case .symbol:
                    self.sendTypingTextAndKey(keyText: charText)
                }
                
                self.vibrate()
            }
            
            // callback: handle auto capitalize
            CurrentKeyboardStatus.didShiftUnlock = {
                // if ShiftStatus is from .lock to .normal, and need capitalize
                self.checkAutoCapitalize()
            }
            
            // callback: handle selected candidate
            self.keyboardView!.selectionView!.candidateWordView!.onSelectedCandidate = { selectedOutput, selectedHanloCandidate in
                self.sendSelectedCandidate(selectedCandidate: selectedOutput)
            }
        }
    }
    
    func addKeyListener() {
        // keyboard input
        for pageView: PageView in self.keyboardView!.typingView!.pages {
            for rowView: RowView in pageView.rowViews {
                for keyView: KeyView in rowView.keyViews {
                    switch keyView.key!.keyType {
                    case .shift:
                        keyView.addTarget(self,
                                      action: #selector(self.keyDownShift(sender:)),
                                      for: .touchDown)
                        keyView.addTarget(self,
                                          action: #selector(self.keyDoubleUpShift(sender:)),
                                          for: .touchDownRepeat)
                    case .backspace:
                        keyView.addTarget(self,
                                      action: #selector(self.keyUpBackspace(sender:)),
                                      for: [.touchUpInside, .touchUpOutside])
                        
                        // long press
                        let deleteButtonLongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(self.keyLongPressBackspace(gestureRecognizer:)))
                        deleteButtonLongPressGestureRecognizer.minimumPressDuration = 0.5
                        keyView.addGestureRecognizer(deleteButtonLongPressGestureRecognizer)
                    case .symbolPage:
                        keyView.addTarget(self,
                                      action: #selector(self.keyUpSymbolPage(sender:)),
                                      for: [.touchUpInside, .touchUpOutside])
                    case .keyboardChange:
                        if #available(iOSApplicationExtension 10.0, *) {
                            keyView.addTarget(self,
                                          action: #selector(handleInputModeList(from:with:)),
                                          for: .allTouchEvents)
                        } else {
                            keyView.addTarget(self,
                                          action: #selector(advanceToNextInputMode),
                                          for: .allTouchEvents)
                        }
                    case .space:
                        keyView.addTarget(self,
                                      action: #selector(self.keyUpSpace(sender:)),
                                      for: [.touchUpInside, .touchUpOutside])
                    case .hanloSwitch:
                        keyView.addTarget(self,
                                      action: #selector(self.keyUpHanloSwitch(sender:)),
                                      for: [.touchUpInside, .touchUpOutside])
                    case .enter:
                        keyView.addTarget(self,
                                      action: #selector(self.keyUpEnter(sender:)),
                                      for: [.touchUpInside, .touchUpOutside])
                    case .lomajiPage:
                        keyView.addTarget(self,
                                      action: #selector(self.keyUpLomajiPage(sender:)),
                                      for: [.touchUpInside, .touchUpOutside])
                    case .charactor:
                        continue
                    }
                }
            }
        }
        
        // menu buttons
        self.keyboardView!.selectionView!.menuBarView!.settingButton.addTarget(self,
                                                                                               action: #selector(self.didTapSettingButton(sender:)),
                                                                                               for: [.touchUpInside])
    }
    
    @objc func didTapSettingButton(sender: UIButton) {
        showSettingView()
    }
    
    @objc func keyDownShift(sender: KeyView) {
        CurrentKeyboardStatus.switchShiftStatue()
        
        self.vibrate()
    }
    
    @objc func keyDoubleUpShift(sender: KeyView) {
        if (self.currentPageIndex == .taigi) {
            CurrentKeyboardStatus.shiftStatus = .locked
        }
        
        self.vibrate()
    }
    
    @objc func keyUpBackspace(sender: KeyView) {
        self.sendBackspaceKey()
        
        checkAutoCapitalize()
        
        self.vibrate()
    }
    
    @objc func keyLongPressBackspace(gestureRecognizer: UILongPressGestureRecognizer) {
        if gestureRecognizer.state == UIGestureRecognizer.State.began {
            if self.keyLongPressBackspaceTimer == nil {
                self.keyLongPressBackspaceTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.sendBackspaceKey), userInfo: nil, repeats: true)
                self.keyLongPressBackspaceTimer!.tolerance = 0.01
            }
        }
        else if gestureRecognizer.state == UIGestureRecognizer.State.ended {
            self.keyLongPressBackspaceTimer?.invalidate()
            self.keyLongPressBackspaceTimer = nil
        }
    }
    
    @objc func keyUpSymbolPage(sender: KeyView) {
        CurrentKeyboardStatus.shiftStatus = .normal
        self.currentPageIndex = .symbol
        
        self.vibrate()
    }
    
    @objc func keyUpSpace(sender: KeyView) {
        self.sendSpaceKey()
        
        self.vibrate()
    }
    
    @objc func keyUpHanloSwitch(sender: KeyView) {
        CurrentKeyboardStatus.switchHanloStatue()
        
        self.vibrate()
    }
    
    @objc func keyUpEnter(sender: KeyView) {
        self.sendTypingTextAndKey(keyText: "\n")
        
        self.vibrate()
    }
    
    @objc func keyUpLomajiPage(sender: KeyView) {
        CurrentKeyboardStatus.shiftStatus = .normal
        self.currentPageIndex = .taigi
        
        self.vibrate()
    }
    
    func sendSpaceKey() {
        if self.hasTypingText() {
            sendTypingText()
        }
        
        self.textDocumentProxy.insertText(" ")
    }
    
    @objc func sendBackspaceKey() {
        if (self.hasTypingText()) {
            self.typingText.remove(at: self.typingText.index(before: self.typingText.endIndex))
        } else {
            self.textDocumentProxy.deleteBackward()
        }
        
        findCandidateWords()
        checkAutoCapitalize()
        
        self.vibrate()
    }
    
    func sendTypingTextAndKey(keyText: String) {
        sendTypingText()
        self.textDocumentProxy.insertText(keyText)
        
        checkAutoCapitalize()
    }
    
    func appendTypingText(text: String) {
        self.typingText.append(contentsOf: text)
        
        findCandidateWords()
        checkAutoCapitalize()
    }
    
    func sendTypingText() {
        let defaultCandidate: String? = self.taigiInputProcessor!.getDefaultCandidate()
        if defaultCandidate != nil {
            self.textDocumentProxy.insertText(defaultCandidate!)
        }
        
        self.typingText = ""
        
        findCandidateWords()
        checkAutoCapitalize()
    }
    
    func sendSelectedCandidate(selectedCandidate: String) {
        self.textDocumentProxy.insertText(selectedCandidate)
        self.typingText = ""
        
        findCandidateWords()
        checkAutoCapitalize()
    }
    
    func hasTypingText() -> Bool {
        return self.typingText.count > 0
    }
    
    func vibrate() {
        if CurrentSetting.isKeyInVibrationEnabled() {
            Haptic.impact(.light).generate()
        }
    }
    
    func showMenu() {
        self.keyboardView!.selectionView!.menuBarView!.isHidden = false
    }
    
    func hideMenu() {
        self.keyboardView!.selectionView!.menuBarView!.isHidden = true
    }
    
    func findCandidateWords() {
        self.taigiInputProcessor!.findCandidateWordsAsync(input: self.typingText)
    }
    
    func checkAutoCapitalize() {
//        print("checkAutoCapitalize: \(String(describing: textDocumentProxy.documentContextBeforeInput))")
        if (self.keyboardView!.typingView!.currentPageIndex != .taigi) {
            return
        }
        
        if self.typingText.isEmpty {
            if textDocumentProxy.documentContextBeforeInput == nil {
                if CurrentKeyboardStatus.shiftStatus != .locked {
                    CurrentKeyboardStatus.shiftStatus = .shifted
                }
            } else {
//                print("textBeforeInput: \(textDocumentProxy.documentContextBeforeInput!)")
                
                var textBeforeInput = textDocumentProxy.documentContextBeforeInput!.trimmingCharacters(in: .whitespaces)
                if !textBeforeInput.isEmpty {
                    textBeforeInput = String(textBeforeInput.suffix(1))
                }
                
//                print("textBeforeInput last char: \(textBeforeInput)")
                
                if textBeforeInput.isEmpty ||
                    KeyboardTemplate.autoCapitalizeEndingTexts.contains(textBeforeInput) {
                    if CurrentKeyboardStatus.shiftStatus != .locked {
                        CurrentKeyboardStatus.shiftStatus = .shifted
                    }
                } else {
                    if CurrentKeyboardStatus.shiftStatus == .shifted {
                        CurrentKeyboardStatus.shiftStatus = .normal
                    }
                }
            }
            
        } else {
            if CurrentKeyboardStatus.shiftStatus == .shifted {
                CurrentKeyboardStatus.shiftStatus = .normal
            }
        }
    }
    
    func showSettingView() {
        if self.keyboardView!.settingView == nil {
            self.keyboardView!.settingView = SettingView()
            self.keyboardView!.settingView!.backButton?.addTarget(self, action: #selector(self.dismissSettingView), for: UIControl.Event.touchUpInside)
            
            self.keyboardView!.settingView!.isHidden = true
            self.keyboardView!.addSubview(self.keyboardView!.settingView!)
            
            self.keyboardView!.settingView!.translatesAutoresizingMaskIntoConstraints = false
            
            let widthConstraint = NSLayoutConstraint(item: self.keyboardView!.settingView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.keyboardView!, attribute: NSLayoutConstraint.Attribute.width, multiplier: 1, constant: 0)
            let heightConstraint = NSLayoutConstraint(item: self.keyboardView!.settingView!, attribute: NSLayoutConstraint.Attribute.height, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.keyboardView!, attribute: NSLayoutConstraint.Attribute.height, multiplier: 1, constant: 0)
            let centerXConstraint = NSLayoutConstraint(item: self.keyboardView!.settingView!, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.keyboardView!, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1, constant: 0)
            let centerYConstraint = NSLayoutConstraint(item: self.keyboardView!.settingView!, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: NSLayoutConstraint.Relation.equal, toItem: self.keyboardView!, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1, constant: 0)
            
            self.keyboardView!.addConstraint(widthConstraint)
            self.keyboardView!.addConstraint(heightConstraint)
            self.keyboardView!.addConstraint(centerXConstraint)
            self.keyboardView!.addConstraint(centerYConstraint)
        }
        
        self.keyboardView!.settingView!.isHidden = false
    }
    
    @objc func dismissSettingView() {
        self.keyboardView!.settingView!.isHidden = true
    }
}
