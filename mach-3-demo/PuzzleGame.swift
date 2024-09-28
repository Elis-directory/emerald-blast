// Import necessary frameworks
import SwiftUI
import SpriteKit
import GameplayKit


// Define the PuzzleGame class inheriting from SKScene
class PuzzleGame: SKScene {
    
    // Declare a 2D array to hold Item objects (representing grid columns)
    var grid = [[Item]]()
    
    // Declare a constant for the size of each item
    var itemSize: CGFloat = 54
    
    // Declare constants for the number of items per column and row
    var itemsPerCol = 7
    var itemsPerRow = 7
    
    // Override the didMove method that is called when the scene is presented
    override func didMove(to view: SKView) {
        
        // Create a background sprite and set its image to "bg1"
        let background = SKSpriteNode(imageNamed: "bg1")
        
        // Position the background in the center of the screen
        background.position = CGPoint(x: view.frame.width / 2, y: view.frame.height / 2)
        
        // Scale the background
        background.setScale(0.55)
        
        // Add the background to the scene
        addChild(background)
        
        // Set the scene size to match screen
        scene?.size = CGSize(width: view.frame.width, height: view.frame.height)
        
        // Loop over each row in the grid
        for r in 0 ..< itemsPerRow {
            
            // Create an array to hold items for the current column
            var col = [Item]()
            
            // Loop over each column in the grid
            for c in 0 ..< itemsPerCol {
                
                // Create a new item for the current row and column
                let item = createItem(row: r, col: c)
                
                // Append the item to the current column
                col.append(item)
            }
            // Append the column to the main 2D array (cols)
            grid.append(col)
        }
        
    }
    
    func positionItem(for item: Item) -> CGPoint {
        
        // Calculate the total width and height of the grid
        let gridWidth = itemSize * CGFloat(itemsPerCol)
        let gridHeight = itemSize * CGFloat(itemsPerRow)
        
        // Set the xOffset and yOffset so that the grid is centered in the scene
        let xOffset: CGFloat = (scene?.size.width ?? 0 - gridWidth) / 10
        let yOffset: CGFloat = (scene?.size.height ?? 0 - gridHeight) / 2.2
        
        // Calculate the x and y positions for the item
        let x = xOffset + itemSize * CGFloat(item.col)
        let y = yOffset + itemSize * CGFloat(item.row)
        
        // Return the CGPoint with the calculated x and y values
        return CGPoint(x: x, y: y)
    }

    
    // Function to create a new item at a given row and column
    func createItem(row: Int, col: Int, startOffScreen: Bool = false) -> Item {
        // Define an array of possible item image names
        let itemImages = ["ruby", "emerald", "sapphire", "platinium", "amber"]
        // Randomly select an image name from the itemImages array
        let itemImage = itemImages[GKRandomSource.sharedRandom().nextInt(upperBound: itemImages.count)]
        
        // Create a new Item object with the selected image name
        let item = Item(imageNamed: itemImage)
        
        // Set the item's name to the selected image name
        item.name = itemImage
        
        // Set the item's row and column
        item.row = row
        item.col = col
        
        // Determine the item's position using the positionItem function
        item.position = positionItem(for: item)
        
        // Set the item's size to itemSize x itemSize
        item.size = CGSize(width: itemSize, height: itemSize * 1.1)
        
        
        // Add the item to the scene
        addChild(item)
        
        // Return the created item
        return item
    }
    
    
}
    

// Define the Item class inheriting from SKSpriteNode
class Item: SKSpriteNode {
    // Declare properties for the row and column, initialized to -1
    var col = -1
    var row = -1
    
    
}

struct ContentView: View {
    let scene = PuzzleGame()
    var body: some View {
        SpriteView(scene: scene)
            .ignoresSafeArea()
    }
}

#Preview {
    ContentView()
}


