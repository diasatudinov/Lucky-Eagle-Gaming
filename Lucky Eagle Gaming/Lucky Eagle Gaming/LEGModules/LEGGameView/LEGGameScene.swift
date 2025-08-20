//
//  GameScene.swift
//  Lucky Eagle Gaming
//
//


import SpriteKit

// MARK: - Models

enum Team { case player, enemy }

enum ChestType: Int {
    case small = 500, medium = 1500, large = 3000
}

struct GridPos: Hashable { var x: Int; var y: Int }

// MARK: - Nodes

final class Unit: SKSpriteNode {
    let team: Team
    let power: Int                 // 3 = сильный, 2 = средний, 1 = слабый
    var cell: GridPos              // текущая клетка

    init(imageNamed: String, team: Team, power: Int, cell: GridPos, size: CGSize) {
        self.team = team
        self.power = power
        self.cell = cell
        let texture = SKTexture(imageNamed: imageNamed)
        super.init(texture: texture, color: .clear, size: size)
        zPosition = 10
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}

final class Chest: SKSpriteNode {
    let type: ChestType
    var cell: GridPos

    init(type: ChestType, cell: GridPos, size: CGSize) {
        self.type = type
        self.cell = cell
        let texture = SKTexture(imageNamed: "chest_\(type)")
        super.init(texture: texture, color: .clear, size: size)
        zPosition = 5
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) not implemented") }
}

extension SKSpriteNode {
    func setScaledToFit(targetSize: CGSize) {
        guard let tex = texture else { return }
        let s = min(targetSize.width/tex.size().width, targetSize.height/tex.size().height)
        size = CGSize(width: tex.size().width * s, height: tex.size().height * s)
    }
}

// MARK: - GameScene

final class LEGGameScene: SKScene {
    let shopVM = NEGShopViewModel()
    var victoryHandler: ((Bool) -> ())?
    var repsSpawnHandler: ((Bool, Int) -> ())?
    
    // Grid
    private let cols = 13, rows = 20
    private let padding: CGFloat = 16
    private let gridNode = SKNode()
    private var tileW: CGFloat = 0
    private var tileH: CGFloat = 0

    // World state
    private var playerUnits: [Unit] = []
    private var enemyUnits:  [Unit] = []
    private var chests: [Chest] = []
    private var occupied: [GridPos: Unit] = [:]

    // Selection
    private var selectedUnit: Unit?

    // Score & timer
    private var playerScore = 0
    private var enemyScore  = 0
    private var remainingTime: TimeInterval = 180
    private var lastUpdateTime: TimeInterval = 0

    // Turn-based
    private enum Turn { case enemy, player }
    private var currentTurn: Turn = .enemy
    private var playerMovesLeft: Int = 0              // «бюджет» ходов на ход игрока (верхняя граница)
    private var movedPlayerUnits: Set<ObjectIdentifier> = [] // кто уже ходил в этом ходу

    // HUD
    private var hudLabel: SKLabelNode!

    private var playerBaseNode: SKSpriteNode!
    private var enemyBaseNode: SKSpriteNode!
    private var playerScoreLabel: SKLabelNode!
    private var enemyScoreLabel: SKLabelNode!
    private var playerScoreBG: SKSpriteNode!
    private var enemyScoreBG: SKSpriteNode!
    
    // MARK: - Scene life cycle

    override func didMove(to view: SKView) {
        backgroundColor = .clear
        addChild(gridNode)
        drawGrid()
        addBasesInCorners()
        spawnChests()
        spawnUnits()
        setupHUD()
        startEnemyTurn()
        updateHUD()
    }

    override func update(_ currentTime: TimeInterval) {
        if lastUpdateTime == 0 { lastUpdateTime = currentTime; return }
        let dt = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        remainingTime -= dt
        if remainingTime <= 0 { endGame(); return }

        updateHUD()
    }

    // MARK: - Grid build & math

    private func drawGrid() {
        gridNode.removeAllChildren()

        let availW = size.width  - padding * 2
        let availH = size.height - padding * 2
        let wFromWidth  = (availW * 2) / CGFloat(cols + rows)
        let wFromHeight = (availH * 4) / CGFloat(cols + rows) // tileH = tileW/2
        tileW = max(8, min(wFromWidth, wFromHeight))
        tileH = tileW / 2

        let lineWidth = 1.0 / (view?.contentScaleFactor ?? UIScreen.main.scale)
        let gridColor = SKColor(white: 1, alpha: 0.35)

        var minX = CGFloat.greatestFiniteMagnitude
        var maxX = -CGFloat.greatestFiniteMagnitude
        var minY = CGFloat.greatestFiniteMagnitude
        var maxY = -CGFloat.greatestFiniteMagnitude

        for y in 0..<rows {
            for x in 0..<cols {
                let c = centerForCell(x: x, y: y)
                let path = diamondPath(center: c)

                let cell = SKShapeNode(path: path)
                cell.strokeColor = gridColor
                cell.fillColor = .clear
                cell.lineWidth = lineWidth
                cell.isAntialiased = true
                gridNode.addChild(cell)

                minX = min(minX, c.x - tileW/2)
                maxX = max(maxX, c.x + tileW/2)
                minY = min(minY, c.y - tileH/2)
                maxY = max(maxY, c.y + tileH/2)
            }
        }

        // центрируем сетку
        let centerX = (minX + maxX)/2
        let centerY = (minY + maxY)/2
        gridNode.position = CGPoint(x: size.width/2 - centerX,
                                    y: size.height/2 - centerY)
    }

    /// клетка -> позиция в gridNode (изометрия "наоборот")
    private func centerForCell(x: Int, y: Int) -> CGPoint {
        let px = CGFloat(x + y) * (tileW/2)
        let py = CGFloat(y - x) * (tileH/2)
        return CGPoint(x: px, y: py)
    }
    private func cellCenter(_ g: GridPos) -> CGPoint { centerForCell(x: g.x, y: g.y) }

    /// позиция сцены -> ближайшая клетка (nil — вне поля)
    private func scenePointToCell(_ pScene: CGPoint) -> GridPos? {
        let p = convert(pScene, to: gridNode)
        let A = tileW/2, B = tileH/2
        guard A > 0, B > 0 else { return nil }
        // x = 0.5*(px/A - py/B), y = 0.5*(px/A + py/B)
        let xF = 0.5 * (p.x / A - p.y / B)
        let yF = 0.5 * (p.x / A + p.y / B)
        let g = GridPos(x: Int(round(xF)), y: Int(round(yF)))
        return isInside(g) ? g : nil
    }

    private func isInside(_ g: GridPos) -> Bool {
        g.x >= 0 && g.x < cols && g.y >= 0 && g.y < rows
    }

    private func neighbors(of g: GridPos) -> [GridPos] {
        [GridPos(x: g.x+1, y: g.y),
         GridPos(x: g.x-1, y: g.y),
         GridPos(x: g.x,   y: g.y+1),
         GridPos(x: g.x,   y: g.y-1)].filter(isInside)
    }

    private func manhattan(_ a: GridPos, _ b: GridPos) -> Int {
        abs(a.x - b.x) + abs(a.y - b.y)
    }

    private func diamondPath(center: CGPoint) -> CGPath {
        let path = CGMutablePath()
        let top    = CGPoint(x: center.x,           y: center.y + tileH/2)
        let right  = CGPoint(x: center.x + tileW/2, y: center.y)
        let bottom = CGPoint(x: center.x,           y: center.y - tileH/2)
        let left   = CGPoint(x: center.x - tileW/2, y: center.y)
        path.addLines(between: [top,right,bottom,left,top])
        return path
    }

    // MARK: - Bases (decor)

    private func addBasesInCorners() {
        let baseTargetSize = CGSize(width: size.width * 0.35, height: size.height * 0.35)

        // пересоздаём, если были
        playerBaseNode?.removeFromParent()
        enemyBaseNode?.removeFromParent()

        // наша база — левый нижний
        guard let baseImage = shopVM.currentBgItem else { return }
        let playerBase = SKSpriteNode(imageNamed: baseImage.image)
        playerBase.setScaledToFit(targetSize: baseTargetSize)
        playerBase.anchorPoint = CGPoint(x: 0, y: 0)
        playerBase.position = CGPoint(x: 16, y: 16)
        addChild(playerBase)
        playerBaseNode = playerBase

        // база соперника — правый верхний
        let enemyBase = SKSpriteNode(imageNamed: "enemyBase")
        enemyBase.setScaledToFit(targetSize: baseTargetSize)
        enemyBase.anchorPoint = CGPoint(x: 1, y: 1)
        enemyBase.position = CGPoint(x: size.width - 16, y: size.height - 16)
        addChild(enemyBase)
        enemyBaseNode = enemyBase

        let bgTargetPlayer = CGSize(width: playerBase.size.width * 0.60,
                                    height: playerBase.size.height * 0.34)
        let bgTargetEnemy  = CGSize(width: enemyBase.size.width * 0.60,
                                    height: enemyBase.size.height * 0.34)
        
        let pBG = SKSpriteNode(imageNamed: "scorePBG")
        pBG.setScaledToFit(targetSize: bgTargetPlayer)
        pBG.zPosition = 1
        pBG.position = CGPoint(x: playerBase.size.width/2, y: playerBase.size.height/2)
        playerBase.addChild(pBG)
        playerScoreBG = pBG
        
        let eBG = SKSpriteNode(imageNamed: "scoreEBG")
        eBG.setScaledToFit(targetSize: bgTargetEnemy)
        eBG.zPosition = 1
        // у правой-верхней базы центр в локальных координатах (0,0), поэтому отрицательные смещения
        eBG.position = CGPoint(x: -enemyBase.size.width/2, y: -enemyBase.size.height/2)
        enemyBase.addChild(eBG)
        enemyScoreBG = eBG
        // --------------------------------------------------------------
        
        // Лейблы очков поверх фона
        func makeScoreLabel(color: SKColor) -> SKLabelNode {
            let l = SKLabelNode(fontNamed: "Menlo-Bold")
            l.fontSize = min(14, baseTargetSize.width * 0.25)
            l.fontColor = color
            l.horizontalAlignmentMode = .center
            l.verticalAlignmentMode = .center
            l.zPosition = 2   // ВЫШЕ, чем фон
            l.text = "0"
            return l
        }
        
        playerScoreLabel = makeScoreLabel(color: .white)
        enemyScoreLabel  = makeScoreLabel(color: .white)
        
        playerScoreLabel.position = pBG.position
        enemyScoreLabel.position  = eBG.position
        
        playerBase.addChild(playerScoreLabel)
        enemyBase.addChild(enemyScoreLabel)
        
        updateScoreLabels()
    }

    private func updateScoreLabels() {
        playerScoreLabel?.text = "\(playerScore)"
        enemyScoreLabel?.text  = "\(enemyScore)"
    }
    
    // MARK: - Spawns (grid-locked)

    private func randomEmptyCell(in rect: (x: ClosedRange<Int>, y: ClosedRange<Int>)) -> GridPos {
        for _ in 0..<256 {
            let g = GridPos(x: Int.random(in: rect.x), y: Int.random(in: rect.y))
            if occupied[g] == nil && !chests.contains(where: { $0.cell == g }) { return g }
        }
        for yy in rect.y {
            for xx in rect.x {
                let g = GridPos(x: xx, y: yy)
                if occupied[g] == nil && !chests.contains(where: { $0.cell == g }) { return g }
            }
        }
        return GridPos(x: rect.x.lowerBound, y: rect.y.lowerBound)
    }

    private func placeUnit(_ u: Unit, at g: GridPos) {
        u.cell = g
        occupied[g] = u
        u.position = gridNode.convert(cellCenter(g), to: self)
        addChild(u)
    }

    private func spawnUnits() {
        occupied.removeAll()
        playerUnits.removeAll()
        enemyUnits.removeAll()

        let unitSize = CGSize(width: tileW * 0.85, height: tileH * 1.5)

        // Игрок — нижне-левая половина
        let pRect = (x: 0...(cols/2), y: (rows/2)...(rows-1))
        for power in [3,2,1] {
            let cell = randomEmptyCell(in: pRect)
            let u = Unit(imageNamed: "player_unit\(power)", team: .player, power: power, cell: cell, size: unitSize)
            placeUnit(u, at: cell)
            playerUnits.append(u)
        }

        // Враг — верхне-правая половина
        let eRect = (x: (cols/2)...(cols-1), y: 0...(rows/2))
        for power in [3,2,1] {
            let cell = randomEmptyCell(in: eRect)
            let u = Unit(imageNamed: "enemy_unit\(power)", team: .enemy, power: power, cell: cell, size: unitSize)
            placeUnit(u, at: cell)
            enemyUnits.append(u)
        }
    }

    private func spawnChests() {
        let chestSize = CGSize(width: tileW * 0.8, height: tileH * 1.2)
        let cRect = (x: (cols/4)...(cols - cols/4 - 1),
                     y: (rows/4)...(rows - rows/4 - 1))
        for _ in 0..<5 {
            let type: ChestType = [.small,.medium,.large].randomElement()!
            let cell = randomEmptyCell(in: cRect)
            let chest = Chest(type: type, cell: cell, size: chestSize)
            chest.position = gridNode.convert(cellCenter(cell), to: self)
            addChild(chest)
            chests.append(chest)
        }
    }

    // MARK: - Player input (only on player's turn)

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard currentTurn == .player, availablePlayerMoves() > 0, !isPaused else { return }
        guard let t = touches.first else { return }
        let p = t.location(in: self)

        // Выбор своей фигурки
        if let u = nodes(at: p).compactMap({ $0 as? Unit }).first, u.team == .player {
            if movedPlayerUnits.contains(ObjectIdentifier(u)) { return } // уже ходил
            selectedUnit = u
            return
        }

        guard let unit = selectedUnit else { return }
        if movedPlayerUnits.contains(ObjectIdentifier(unit)) { return }

        guard let targetCell = scenePointToCell(p) else { return }
        guard manhattan(unit.cell, targetCell) == 1 else { return }               // на 1 клетку
        if let occ = occupied[targetCell], occ.team == unit.team { return }       // нельзя в союзника

        // снять занятость текущей
        occupied[unit.cell] = nil

        let finishPlayerStep: () -> Void = { [weak self, weak unit] in
            guard let self = self, let unit = unit else { return }
            self.movedPlayerUnits.insert(ObjectIdentifier(unit))
            self.playerMovesLeft = max(0, self.playerMovesLeft - 1)               // расход хода
            self.selectedUnit = nil
            self.checkEndEarly()
            self.recomputeOrEndPlayerTurn()
        }

        if let enemy = occupied[targetCell], enemy.team != unit.team {
            resolveBattle(attacker: unit, defender: enemy) {
                finishPlayerStep()
            }
        } else {
            moveUnit(unit, to: targetCell) {
                finishPlayerStep()
            }
        }
    }

    private func moveUnit(_ unit: Unit, to newCell: GridPos, completion: (() -> Void)? = nil) {
        let targetPoint = gridNode.convert(cellCenter(newCell), to: self)
        unit.cell = newCell
        occupied[newCell] = unit
        let move = SKAction.move(to: targetPoint, duration: 0.18)
        unit.run(move) { [weak self, weak unit] in
            guard let self = self, let unit = unit else { completion?(); return }
            self.checkChestCollection(for: unit)
            self.checkEndEarly()
            completion?()
        }
    }

    // MARK: - Enemy turn (sequential, one step per alive unit)

    private func startEnemyTurn() {
        guard !isPaused else { return }
        currentTurn = .enemy
        movedPlayerUnits.removeAll()
        // playerMovesLeft будет выставлен в startPlayerTurn
        updateHUD()
        processEnemy(at: 0)
    }

    private func processEnemy(at index: Int) {
        sleep(1)
        if isPaused { return }
        guard !enemyUnits.isEmpty else { startPlayerTurn(); return }
        if index >= enemyUnits.count { startPlayerTurn(); return }

        let e = enemyUnits[index]
        guard enemyUnits.contains(where: { $0 === e }) else { processEnemy(at: index + 1); return }

        // цель: ближ. сундук -> ближ. игрок -> угол игрока
        let targets: [GridPos] = {
            if let chest = chests.min(by: { manhattan(e.cell, $0.cell) < manhattan(e.cell, $1.cell) }) {
                return [chest.cell]
            }
            if let p = playerUnits.min(by: { manhattan(e.cell, $0.cell) < manhattan(e.cell, $1.cell) }) {
                return [p.cell]
            }
            return [GridPos(x: 0, y: rows-1)]
        }()

        var best: GridPos?
        var bestScore = Int.max
        for n in neighbors(of: e.cell).shuffled() {
            if let occ = occupied[n], occ.team == e.team { continue }
            let score = targets.map { manhattan(n, $0) }.min() ?? Int.max
            if score < bestScore { bestScore = score; best = n }
        }

        guard let step = best else { processEnemy(at: index + 1); return }

        if let enemy = occupied[step], enemy.team != e.team {
            resolveBattle(attacker: e, defender: enemy) { [weak self] in
                self?.processEnemy(at: index + 1)
            }
        } else if occupied[step] == nil {
            occupied[e.cell] = nil
            moveUnit(e, to: step) { [weak self] in
                self?.processEnemy(at: index + 1)
            }
        } else {
            processEnemy(at: index + 1)
        }
    }

    private func startPlayerTurn() {
        guard !isPaused else { return }
        currentTurn = .player
        movedPlayerUnits.removeAll()
        playerMovesLeft = min(3, playerUnits.count)      // бюджет = живые (до 3)
        recomputeOrEndPlayerTurn()
        updateHUD()
    }

    // MARK: - Combat

    private func resolveBattle(attacker: Unit, defender: Unit, completion: (() -> Void)? = nil) {
        // защита от гонок
        guard occupied[attacker.cell] === attacker, occupied[defender.cell] === defender else {
            completion?(); return
        }

        let attackerWins: Bool = {
            if attacker.power > defender.power { return true }
            if attacker.power < defender.power { return false }
            return Bool.random()
        }()

        if attackerWins {
            if attacker.team == .player {
                playerScore += 500
                repsSpawnHandler?(true, 2)
            } else {
                enemyScore += 500
                repsSpawnHandler?(true, 3)
            }
            let targetCell = defender.cell
            removeUnit(defender)                 // чистит occupied[targetCell]
            occupied[attacker.cell] = nil
            moveUnit(attacker, to: targetCell) {
                completion?()
            }
        } else {
            if defender.team == .player {
                playerScore += 500
                repsSpawnHandler?(true, 2)
            } else {
                enemyScore += 500
                repsSpawnHandler?(true, 3)
            }
            let old = attacker.cell
            removeUnit(attacker)
            occupied[old] = nil
            completion?()
        }
        checkEndEarly()
    }

    private func removeUnit(_ u: Unit) {
        occupied[u.cell] = nil
        // если этот юнит уже числился «ходившим» — убрать из множества
        movedPlayerUnits.remove(ObjectIdentifier(u))
        if u.team == .player { playerUnits.removeAll { $0 === u } }
        else { enemyUnits.removeAll { $0 === u } }
        u.removeFromParent()

        // если юнит убит во время хода игрока — пересчитать возможные ходы
        if currentTurn == .player && u.team == .player {
            recomputeOrEndPlayerTurn()
        }
    }

    // MARK: - Chests

    private func checkChestCollection(for unit: Unit) {
        if let i = chests.firstIndex(where: { $0.cell == unit.cell }) {
            let chest = chests.remove(at: i)
            if unit.team == .player {
                playerScore += chest.type.rawValue
                repsSpawnHandler?(true, 4)
            } else {
                enemyScore += chest.type.rawValue
            }
            
            chest.removeFromParent()
        }
    }

    // MARK: - Turn helpers (dynamic moves)

    /// Сколько реально ходов осталось прямо сейчас (учитывая живых и тех, кто уже ходил)
    private func availablePlayerMoves() -> Int {
        let maxByUnits = min(3, playerUnits.count)
        let remainByUnits = max(0, maxByUnits - movedPlayerUnits.count)
        return min(playerMovesLeft, remainByUnits)
    }

    /// Пересчитать оставшиеся ходы и, при необходимости, передать ход ИИ
    private func recomputeOrEndPlayerTurn() {
        // clamp playerMovesLeft к максимально допустимому по живым юнитам
        let maxByUnits = min(3, playerUnits.count)
        let allowedNow = max(0, maxByUnits - movedPlayerUnits.count)
        playerMovesLeft = min(playerMovesLeft, allowedNow)

        if availablePlayerMoves() <= 0 || playerUnits.isEmpty {
            startEnemyTurn()
        }
        updateHUD()
    }

    // MARK: - Win conditions

    private func checkEndEarly() {
        if playerUnits.isEmpty || enemyUnits.isEmpty { endGame() }
    }

    private func endGame() {
        guard !isPaused else { return }
        let winner: String
        if playerUnits.isEmpty {
            winner = "Enemy Wins!"
            victoryHandler?(false)
        }
        else if enemyUnits.isEmpty {
            winner = "Player Wins!"
            victoryHandler?(true)
        }
        else if playerScore > enemyScore {
            winner = "Player Wins!"
            victoryHandler?(true)
        }
        else if enemyScore > playerScore {
            winner = "Enemy Wins!"
            victoryHandler?(false)
        }
        else {
            winner = "Draw"
            victoryHandler?(false)
        }
        isPaused = true
    }

    // MARK: - HUD

    private func setupHUD() {
        hudLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        hudLabel.fontSize = 16
        hudLabel.horizontalAlignmentMode = .center
        hudLabel.verticalAlignmentMode = .top
        hudLabel.position = CGPoint(x: size.width/2, y: size.height - 8)
        hudLabel.zPosition = 150
        addChild(hudLabel)
    }

    private func updateHUD() {
        let timeText = "⏱ \(max(0, Int(remainingTime)))"
//        let scoreText = "🟦 \(playerScore) : \(enemyScore) 🟥"
//        let turnText: String = (currentTurn == .enemy)
//            ? "Ход ИИ…"
//            : "Ваш ход (\(availablePlayerMoves()))"
        hudLabel.text = "\(timeText)"
        updateScoreLabels()
    }
}
