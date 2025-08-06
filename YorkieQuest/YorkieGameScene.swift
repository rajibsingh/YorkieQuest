import SpriteKit
import SwiftUI

class YorkieGameScene: SKScene {
    private var yorkieSprite: SKSpriteNode!
    private var yorkiePosition: CGPoint = CGPoint.zero
    private var targetPosition: CGPoint?
    private var lastInteractionTime: TimeInterval = 0
    private var isMoving = false
    private var currentAnimation: YorkieAnimation?
    
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
        setupYorkie()
        lastInteractionTime = CACurrentMediaTime()
    }
    
    private func setupYorkie() {
        let texture = createTextureFromSpriteSheet(row: YorkieAnimation.idle.row, frame: 0)
        yorkieSprite = SKSpriteNode(texture: texture)
        yorkieSprite.setScale(yorkieScale)
        yorkieSprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
        yorkiePosition = yorkieSprite.position
        addChild(yorkieSprite)
        
        startAnimation(.idle)
    }
    
    private func createTextureFromSpriteSheet(row: Int, frame: Int) -> SKTexture {
        let spriteSheet = SKTexture(imageNamed: "yorkie")
        
        // Let's get the actual sprite sheet dimensions first
        let sheetSize = spriteSheet.size()
        print("Sprite sheet size: \(sheetSize)")
        
        // Assume 4 columns and calculate rows based on sheet dimensions
        let cols = 4
        let spriteWidth = sheetSize.width / CGFloat(cols)
        let spriteHeight = spriteWidth // Assume square sprites
        
        print("Calculated sprite size: \(spriteWidth) x \(spriteHeight)")
        
        let x = CGFloat(frame) * spriteWidth
        let y = CGFloat(row) * spriteHeight
        
        let rect = CGRect(
            x: x / sheetSize.width,
            y: 1.0 - (y + spriteHeight) / sheetSize.height,
            width: spriteWidth / sheetSize.width,
            height: spriteHeight / sheetSize.height
        )
        
        print("Extracting sprite at row \(row), frame \(frame): rect = \(rect)")
        
        return SKTexture(rect: rect, in: spriteSheet)
    }
    
    private func startAnimation(_ animation: YorkieAnimation) {
        guard currentAnimation != animation else { return }
        
        yorkieSprite.removeAllActions()
        currentAnimation = animation
        
        var textures: [SKTexture] = []
        let frameCount = animation.frameCount
        
        for frame in 0..<frameCount {
            let texture = createTextureFromSpriteSheet(row: animation.row, frame: frame)
            textures.append(texture)
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
        
        let animateAction = SKAction.animate(with: textures, timePerFrame: animationDuration / Double(frameCount))
        let repeatAction = SKAction.repeatForever(animateAction)
        yorkieSprite.run(repeatAction, withKey: "animation")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        targetPosition = location
        lastInteractionTime = CACurrentMediaTime()
        moveToTarget()
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
        
        if animation == .walkLeft || animation == .runLeft {
            yorkieSprite.xScale = -abs(yorkieSprite.xScale)
        } else {
            yorkieSprite.xScale = abs(yorkieSprite.xScale)
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
        
        if !isMoving && currentTime - lastInteractionTime > snoozeDelay {
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