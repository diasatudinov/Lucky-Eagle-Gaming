import SpriteKit

final class GameScene: SKScene {
    // Размер сетки: колонки × строки
    private let cols = 13
    private let rows = 20
    private let padding: CGFloat = 16

    private let gridNode = SKNode()
    private var tileW: CGFloat = 0   // ширина ромба (плитки)
    private var tileH: CGFloat = 0   // высота ромба (плитки), = tileW/2 для 2:1

    override func didMove(to view: SKView) {
        backgroundColor = .black
        if gridNode.parent == nil { addChild(gridNode) }
        drawGrid()
    }

    override func didChangeSize(_ oldSize: CGSize) {
        // перестроим при повороте/смене размера
        drawGrid()
    }

    // MARK: - Построение сетки

    private func drawGrid() {
        gridNode.removeAllChildren()

        // Доступная область
        let availW = size.width  - padding * 2
        let availH = size.height - padding * 2

        // Подбор ширины плитки, чтобы вся сетка влезла
        // Для изо-сетки габариты ≈ ((cols+rows) * tileW / 2) × ((cols+rows) * tileH / 2)
        // при tileH = tileW/2
        let wFromWidth  = (availW * 2) / CGFloat(cols + rows)
        let wFromHeight = (availH * 4) / CGFloat(cols + rows)
        tileW = min(wFromWidth, wFromHeight)
        tileH = tileW / 2

        let lineWidth = 1.0 / (view?.contentScaleFactor ?? UIScreen.main.scale)
        let gridColor = SKColor(white: 1.0, alpha: 0.35)

        // Для центрирования посчитаем границы
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

                // расширяем габариты с учётом половин плитки
                minX = min(minX, c.x - tileW / 2)
                maxX = max(maxX, c.x + tileW / 2)
                minY = min(minY, c.y - tileH / 2)
                maxY = max(maxY, c.y + tileH / 2)
            }
        }

        // Центрируем сетку в сцене
        let centerX = (minX + maxX) / 2
        let centerY = (minY + maxY) / 2
        gridNode.position = CGPoint(
            x: size.width  / 2 - centerX,
            y: size.height / 2 - centerY
        )

        addBases()
    }

    // Центр ромбика для клетки (x, y) в изометрической проекции 2:1
    private func centerForCell(x: Int, y: Int) -> CGPoint {
        let px = CGFloat(x - y) * (tileW / 2)
        let py = CGFloat(x + y) * (tileH / 2)
        return CGPoint(x: px, y: py)
    }

    private func diamondPath(center: CGPoint) -> CGPath {
        let path = CGMutablePath()
        let top    = CGPoint(x: center.x,           y: center.y + tileH / 2)
        let right  = CGPoint(x: center.x + tileW/2, y: center.y)
        let bottom = CGPoint(x: center.x,           y: center.y - tileH / 2)
        let left   = CGPoint(x: center.x - tileW/2, y: center.y)
        path.move(to: top)
        path.addLine(to: right)
        path.addLine(to: bottom)
        path.addLine(to: left)
        path.addLine(to: top)
        return path
    }

    // MARK: - Базы (углы поля)

    private func addBases() {
        // Наша — левый нижний ромб: (0, rows-1)
        let playerPos = centerForCell(x: 0, y: rows - 1)
        // Соперник — правый верхний ромб: (cols-1, 0)
        let enemyPos  = centerForCell(x: cols - 1, y: 0)

        let sizeEdge = min(tileW, tileH) * 0.9

        let playerBase = SKShapeNode(rectOf: CGSize(width: sizeEdge, height: sizeEdge),
                                     cornerRadius: sizeEdge * 0.15)
        playerBase.strokeColor = .systemBlue
        playerBase.fillColor = .clear
        playerBase.lineWidth = 2
        playerBase.zPosition = 10
        playerBase.position = playerPos
        gridNode.addChild(playerBase)

        let enemyBase = SKShapeNode(rectOf: CGSize(width: sizeEdge, height: sizeEdge),
                                    cornerRadius: sizeEdge * 0.15)
        enemyBase.strokeColor = .systemRed
        enemyBase.fillColor = .clear
        enemyBase.lineWidth = 2
        enemyBase.zPosition = 10
        enemyBase.position = enemyPos
        gridNode.addChild(enemyBase)

        // подписи (необязательно)
        func makeLabel(_ text: String, color: SKColor) -> SKLabelNode {
            let l = SKLabelNode(text: text)
            l.fontName = "Menlo-Bold"
            l.fontSize = sizeEdge * 0.35
            l.fontColor = color
            l.verticalAlignmentMode = .center
            l.zPosition = 11
            return l
        }
        playerBase.addChild(makeLabel("BASE", color: .systemBlue))
        enemyBase.addChild(makeLabel("ENEMY", color: .systemRed))
    }
}