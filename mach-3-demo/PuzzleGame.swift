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
    
    // Declare a set to store matched items
    var currentMatch = Set<Item>()
    
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
        let yOffset: CGFloat = (scene?.size.height ?? 0 - gridHeight) / 2.3
        
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
        
       
        
        // Check if the item should start off screen, if true, animate it into position
        if startOffScreen {
            let finalPosition = positionItem(for: item)
            item.position = finalPosition
            item.position.y += 600
                  
            let downAction = SKAction.move(to: finalPosition, duration: 0.4)
            item.run(downAction)
            self.isUserInteractionEnabled = true
        } else {
            item.position = positionItem(for: item)
        }
              
        // Set the item's size to itemSize x itemSize
        item.size = CGSize(width: itemSize, height: itemSize * 1.1)
        // Add the item to the scene
        addChild(item)
        
        // Return the created item
        return item
    }
    
    func findItem(point: CGPoint) -> Item? {
        let item = nodes(at: point).compactMap{$0 as? Item}
        return item.first
    }
    
    // Function to find matches for a given item
        func findMatch(original: Item) {
            // Declare an array to store potential matching items
            var checkItems = [Item?]()
            
            // Insert the original item into the currentMatch set
            currentMatch.insert(original)
            
            // Get the position of the original item
            let position = original.position
            
            // Add surrounding items to the checkItems array (above, below, left, right)
            checkItems.append(findItem(point: CGPoint(x: position.x, y: position.y - itemSize)))
            checkItems.append(findItem(point: CGPoint(x: position.x, y: position.y + itemSize)))
            checkItems.append(findItem(point: CGPoint(x: position.x - itemSize, y: position.y)))
            checkItems.append(findItem(point: CGPoint(x: position.x + itemSize, y: position.y)))
            
            // Loop through each item in checkItems
            for case let check? in checkItems {
                // If the item is already in the currentMatch set, skip it
                if currentMatch.contains(check) { continue }
                
                // If the item's name matches the original item's name, find more matches
                if check.name == original.name {
                    findMatch(original: check)
                }
            }
        }
        
       
       // Function to remove matches from the scene
       func removeMatches() {
           let sortedMatched = currentMatch.sorted {
               $0.row > $1.row
           }
           
           // Loop through each item in the currentMatch set and remove it from the parent (scene)
           for item in sortedMatched {
               grid[item.col].remove(at: item.row)
               item.removeFromParent()
           }
           
       }
       
       // Function to handle touch events in the scene
       override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
           
           // Ensure there's a touch event
           guard let touch = touches.first else {return}
           
           // Get the location of the touch in the scene
           let location = touch.location(in: self)
           
           // Find the item at the location of the touch
           guard let tappedItem = findItem(point: location) else {return}
           
           isUserInteractionEnabled = false
           // Clear the currentMatch set and find matches for the tapped item
           currentMatch.removeAll()
           findMatch(original: tappedItem)
           
           // Remove matched items from the scene
           removeMatches()
           moveDown()
       }
       
    // Function to move down items when a match is removed
    func moveDown() {
        for (columnIndex, col) in grid.enumerated() {
            for (rowIndex, item) in col.enumerated() {
                item.row = rowIndex
                
                let downAction = SKAction.move(to: positionItem(for: item), duration: 0.3)
                item.run(downAction)
            }
            
            while grid[columnIndex].count < itemsPerRow {
                let item = createItem(row:grid[columnIndex].count, col: columnIndex, startOffScreen: true)
                grid[columnIndex].append(item)
            }
        }
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


