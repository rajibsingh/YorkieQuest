import SpriteKit
import SwiftUI
#if os(macOS)
import AppKit
#endif

class YorkieGameScene: SKScene {
    private var yorkieSprite: SKSpriteNode!
    private var yorkiePosition: CGPoint = CGPoint.zero
    private var targetPosition: CGPoint?
    private var lastInteractionTime: TimeInterval = 0
    private var isMoving = false
    private var currentAnimation: YorkieAnimation?
    
    // Texture caching
    private var spriteSheetTexture: SKTexture!
    private var textureCache: [String: [SKTexture]] = [:]
    
    // Keyboard input state
    private var keysPressed: Set<String> = []
    private var currentDirection: CGPoint = CGPoint.zero
    private var keyboardMovementSpeed: CGFloat = 150.0
    
    private let spriteSize = CGSize(width: 32, height: 32)
    private let yorkieScale: CGFloat = 2.0
    private let walkSpeed: CGFloat = 100.0
    private let runSpeed: CGFloat = 200.0
    private let runThreshold: CGFloat = 150.0
    private let snoozeDelay: TimeInterval = 10.0
    
    enum YorkieAnimation {
        case walkUp, walkRight, walkDown, walkLeft, idle, snooze, runRight, runLeft
        
        var row: Int {
            switch self {
            case .walkUp: return 2
            case .walkRight: return 1
            case .walkDown: return 0
            case .walkLeft: return 1
            case .idle: return 4
            case .snooze: return 7
            case .runRight: return 8
            case .runLeft: return 9
            }
        }
        
        var frameCount: Int {
            switch self {
            case .walkUp, .walkRight, .walkDown, .walkLeft: return 4
            case .idle: return 4
            case .snooze: return 2
            case .runRight: return 3
            case .runLeft: return 3
            }
        }
    }
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor(red: 0.8, green: 0.9, blue: 0.8, alpha: 1.0)
        spriteSheetTexture = SKTexture(imageNamed: "yorkie")
        setupYorkie()
        lastInteractionTime = CACurrentMediaTime()
    }
    
    private func setupYorkie() {
        let texture = createTextureFromSpriteSheet(row: YorkieAnimation.idle.row, frame: 0)
        yorkieSprite = SKSpriteNode(texture: texture)
        yorkieSprite.setScale(yorkieScale)
        yorkieSprite.anchorPoint = CGPoint(x: 0.5, y: 0.5) // Center anchor to prevent clipping
        yorkieSprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
        yorkiePosition = yorkieSprite.position
        addChild(yorkieSprite)
        
        startAnimation(.idle)
    }
    
    private func createTextureFromSpriteSheet(row: Int, frame: Int) -> SKTexture {
        // Get the actual sprite sheet dimensions
        let sheetSize = spriteSheetTexture.size()
        
        // Use 4 columns layout as specified in CLAUDE.md
        let cols = 4
        let spriteWidth = sheetSize.width / CGFloat(cols)
        let spriteHeight = spriteWidth // Keep square assumption but ensure proper bounds
        
        // Calculate position with proper bounds checking
        let x = CGFloat(frame) * spriteWidth
        let y = CGFloat(row) * spriteHeight
        
        // Ensure we don't exceed sheet boundaries
        let clampedWidth = min(spriteWidth, sheetSize.width - x)
        let clampedHeight = min(spriteHeight, sheetSize.height - y)
        
        let rect = CGRect(
            x: x / sheetSize.width,
            y: 1.0 - (y + clampedHeight) / sheetSize.height,
            width: clampedWidth / sheetSize.width,
            height: clampedHeight / sheetSize.height
        )
        
        let texture = SKTexture(rect: rect, in: spriteSheetTexture)
        // Ensure texture filtering is set to nearest neighbor to prevent blurring/clipping
        texture.filteringMode = .nearest
        
        return texture
    }
    
    private func startAnimation(_ animation: YorkieAnimation) {
        guard currentAnimation != animation else { return }
        
        yorkieSprite.removeAllActions()
        currentAnimation = animation
        
        // Get cached textures or create them
        let animationKey = "\(animation.row)_\(animation.frameCount)"
        let textures: [SKTexture]
        
        if let cachedTextures = textureCache[animationKey] {
            textures = cachedTextures
        } else {
            var newTextures: [SKTexture] = []
            let frameCount = animation.frameCount
            
            for frame in 0..<frameCount {
                let texture = createTextureFromSpriteSheet(row: animation.row, frame: frame)
                newTextures.append(texture)
            }
            textureCache[animationKey] = newTextures
            textures = newTextures
        }
        
        let animationDuration: TimeInterval
        switch animation {
        case .walkUp, .walkRight, .walkDown, .walkLeft:
            animationDuration = 0.6
        case .runRight, .runLeft:
            animationDuration = 0.4
        case .idle:
            animationDuration = 2.0
        case .snooze:
            animationDuration = 1.5
        }
        
        let animateAction = SKAction.animate(with: textures, timePerFrame: animationDuration / Double(textures.count))
        let repeatAction = SKAction.repeatForever(animateAction)
        yorkieSprite.run(repeatAction, withKey: "animation")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Stop keyboard movement when touch begins
        currentDirection = CGPoint.zero
        keysPressed.removeAll()
        
        targetPosition = location
        lastInteractionTime = CACurrentMediaTime()
        moveToTarget()
    }
    
    // MARK: - Keyboard Input Handling
    
    #if os(macOS)
    override func keyDown(with event: NSEvent) {
        guard let characters = event.charactersIgnoringModifiers else { return }
        
        for character in characters {
            let key = String(character).lowercased()
            
            // Handle special keys using key codes
            var keyString = key
            switch event.keyCode {
            case 126: keyString = "up"    // Up arrow
            case 125: keyString = "down"  // Down arrow  
            case 123: keyString = "left"  // Left arrow
            case 124: keyString = "right" // Right arrow
            default: break
            }
            
            if ["up", "down", "left", "right"].contains(keyString) {
                keysPressed.insert(keyString)
                updateKeyboardMovement()
                lastInteractionTime = CACurrentMediaTime()
            }
        }
    }
    
    override func keyUp(with event: NSEvent) {
        guard let characters = event.charactersIgnoringModifiers else { return }
        
        for character in characters {
            let key = String(character).lowercased()
            
            // Handle special keys using key codes
            var keyString = key
            switch event.keyCode {
            case 126: keyString = "up"    // Up arrow
            case 125: keyString = "down"  // Down arrow
            case 123: keyString = "left"  // Left arrow
            case 124: keyString = "right" // Right arrow
            default: break
            }
            
            if ["up", "down", "left", "right"].contains(keyString) {
                keysPressed.remove(keyString)
                updateKeyboardMovement()
            }
        }
    }
    #endif
    
    // iOS Keyboard Support (External keyboards and iPad)  
    #if os(iOS)
    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            guard let key = press.key else { continue }
            
            var keyString = ""
            switch key.keyCode {
            case .keyboardUpArrow: keyString = "up"
            case .keyboardDownArrow: keyString = "down"
            case .keyboardLeftArrow: keyString = "left"
            case .keyboardRightArrow: keyString = "right"
            default: break
            }
            
            if !keyString.isEmpty {
                keysPressed.insert(keyString)
                updateKeyboardMovement()
                lastInteractionTime = CACurrentMediaTime()
            }
        }
        
        super.pressesBegan(presses, with: event)
    }
    
    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        for press in presses {
            guard let key = press.key else { continue }
            
            var keyString = ""
            switch key.keyCode {
            case .keyboardUpArrow: keyString = "up"
            case .keyboardDownArrow: keyString = "down"
            case .keyboardLeftArrow: keyString = "left"
            case .keyboardRightArrow: keyString = "right"
            default: break
            }
            
            if !keyString.isEmpty {
                keysPressed.remove(keyString)
                updateKeyboardMovement()
            }
        }
        
        super.pressesEnded(presses, with: event)
    }
    #endif
    
    private func updateKeyboardMovement() {
        // Calculate direction based on pressed keys
        var direction = CGPoint.zero
        
        if keysPressed.contains("up") {
            direction.y += 1
        }
        if keysPressed.contains("down") {
            direction.y -= 1
        }
        if keysPressed.contains("left") {
            direction.x -= 1
        }
        if keysPressed.contains("right") {
            direction.x += 1
        }
        
        // Normalize diagonal movement
        if direction.x != 0 && direction.y != 0 {
            let length = sqrt(direction.x * direction.x + direction.y * direction.y)
            direction.x /= length
            direction.y /= length
        }
        
        currentDirection = direction
        
        // Stop any existing movement actions
        yorkieSprite.removeAction(forKey: "move")
        targetPosition = nil
        
        // Update animation based on direction
        if direction != CGPoint.zero {
            isMoving = true
            let animation = getAnimationForDirection(direction, isRunning: false)
            startAnimation(animation)
            
            // Handle horizontal flipping properly to avoid clipping
            if animation == .walkLeft || animation == .runLeft {
                yorkieSprite.xScale = -abs(yorkieScale)
            } else {
                yorkieSprite.xScale = abs(yorkieScale)
            }
        } else {
            isMoving = false
            startAnimation(.idle)
        }
    }
    
    private func moveToTarget() {
        guard let target = targetPosition else { return }
        
        isMoving = true
        let distance = yorkiePosition.distance(to: target)
        let isRunning = distance > runThreshold
        let speed = isRunning ? runSpeed : walkSpeed
        
        let direction = target - yorkiePosition
        let normalizedDirection = direction.normalized
        
        let animation = getAnimationForDirection(normalizedDirection, isRunning: isRunning)
        startAnimation(animation)
        
        // Handle horizontal flipping properly to avoid clipping
        if animation == .walkLeft || animation == .runLeft {
            yorkieSprite.xScale = -abs(yorkieScale)
        } else {
            yorkieSprite.xScale = abs(yorkieScale)
        }
        
        let moveTime = TimeInterval(distance / speed)
        let moveAction = SKAction.move(to: target, duration: moveTime)
        
        yorkieSprite.run(moveAction) { [weak self] in
            self?.yorkiePosition = target
            self?.isMoving = false
            self?.startAnimation(.idle)
            self?.targetPosition = nil
        }
    }
    
    private func getAnimationForDirection(_ direction: CGPoint, isRunning: Bool) -> YorkieAnimation {
        let absX = abs(direction.x)
        let absY = abs(direction.y)
        
        if absX > absY {
            if direction.x > 0 {
                return isRunning ? .runRight : .walkRight
            } else {
                return isRunning ? .runLeft : .walkLeft
            }
        } else {
            if direction.y > 0 {
                return .walkUp
            } else {
                return .walkDown
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // Handle keyboard movement
        if currentDirection != CGPoint.zero {
            let deltaTime = 1.0 / 60.0 // Assume 60 FPS
            let movement = CGPoint(
                x: currentDirection.x * keyboardMovementSpeed * deltaTime,
                y: currentDirection.y * keyboardMovementSpeed * deltaTime
            )
            
            let newPosition = CGPoint(
                x: yorkieSprite.position.x + movement.x,
                y: yorkieSprite.position.y + movement.y
            )
            
            // Keep sprite within bounds
            let clampedPosition = CGPoint(
                x: max(0, min(size.width, newPosition.x)),
                y: max(0, min(size.height, newPosition.y))
            )
            
            yorkieSprite.position = clampedPosition
            yorkiePosition = clampedPosition
            
            isMoving = true
        }
        
        // Handle snooze animation when not moving
        if !isMoving && currentDirection == CGPoint.zero && currentTime - lastInteractionTime > snoozeDelay {
            if currentAnimation != .snooze {
                startAnimation(.snooze)
            }
        }
    }
}

extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
    
    var normalized: CGPoint {
        let length = sqrt(x * x + y * y)
        return length > 0 ? CGPoint(x: x / length, y: y / length) : CGPoint.zero
    }
    
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
}