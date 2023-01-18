package;

// required imports
import flixel.FlxG;
import flixel.FlxState;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;
import flixel.text.FlxText;

// statically an array which can be used to represent the grid top-bottom
		// 0 = Empty space
		// 1 = Player Block
		// 2 = Exit Block
		// 3 = Wall
var grid:Array<Array<Int>> = [  [0, 0, 0, 3, 0, 2],
								[0, 3, 0, 3, 0, 3],
								[0, 3, 0, 3, 0, 3],
								[0, 3, 0, 3, 0, 0],
								[0, 3, 0, 3, 3, 0],
								[1, 3, 0, 0, 0, 0]];

// variables to store the player position
var playerY:Int = 5;
var playerX:Int = 0;

// variable to determine whether the player has moved or not yet
var firstMove:Bool = true;

class PlayState extends FlxState
{	

	// define required variables for grid
	var walls:FlxTypedGroup<FlxSprite>;
	var empties:FlxTypedGroup<FlxSprite>;
	var player:FlxSprite;
	var exit:FlxSprite;

	// function to draw grid on screen
	public function drawGrid() {

		// Iterate over grid to construct player, grid, walls
		add(walls = new FlxTypedGroup<FlxSprite>());
		add(empties = new FlxTypedGroup<FlxSprite>());
		var y = 0;
		var x = 0;
		for (row in grid) {
			x = 0;
			for (entry in row) {

				// empty space
				if (entry == 0) {
					var space = new FlxSprite(x*100, y*100);
					space.makeGraphic(100, 100, FlxColor.WHITE);
					space.solid = true;
					empties.add(space);
				}

				// player
				else if (entry == 1) {
					player = new FlxSprite(0, 500);
					player.makeGraphic(100, 100, FlxColor.BLUE);
					player.solid = true;
					add(player);
				}

				// exit
				else if (entry == 2) {
					exit = new FlxSprite(500, 0);
					exit.makeGraphic(100, 100, FlxColor.GREEN);
					exit.solid = true;
					add(exit);
				}


				// walls (represented by 3 in grid)
				else {
					var wall = new FlxSprite(x*100, y*100);
					wall.makeGraphic(100, 100, FlxColor.BLACK); // currently white, change after
					wall.solid = true;
					walls.add(wall);
				}

				x += 1;
			} 
			y += 1;
		}

	}

	override public function create()
	{
		super.create();
		drawGrid();

	}

	// shows success screen when player reaches end
	public function success() {
		// show success text
		var text = new FlxText(0, 0, FlxG.width, "Success!", 64);
		text.setFormat(null, 64, FlxColor.RED, FlxTextAlign.CENTER);
		add(text);
	}

	// check if player at end
	static function checkSuccess():Bool {
		if (playerY == 0 && playerX == 5){
			return true;
		}
		else return false;
	}

	// determines whether to mark a space as visited or empty
	// marks a space as visited as long as both the the current and next block are not already marked as visited
	public function visitedOrEmpty(x:Int, y:Int) {
		if (grid[playerY][playerX] != 4 && grid[playerY+y][playerX+x] != 4) {
			grid[playerY][playerX] = 4;
		}
		else grid[playerY][playerX] = 0;
	}

	// define function that will allow for movement of the block
	// checks grid to see if move is possible, then moves there
	// also marks each previous space after moving as visited
	// if you are on a visited space, moving to a visited space, the space you moved from will be marked as empty
	public function moveBlock(direction:String) {

		// left
		if (direction == "left" && playerX-1 >= 0 && grid[playerY][playerX-1] != 3) {
			visitedOrEmpty(-1, 0);
			player.x -= 100;
			playerX -= 1;
			if(!checkSuccess())
				grid[playerY][playerX] = 1;
		}

		// right
		else if (direction == "right" && playerX+1 <= 5 && grid[playerY][playerX+1] != 3) {
			visitedOrEmpty(1, 0);
			player.x += 100;
			playerX += 1;
			if(!checkSuccess())
				grid[playerY][playerX] = 1;
		}

		// down
		else if (direction == "down" && playerY+1 <= 5 && grid[playerY+1][playerX] != 3) {
			visitedOrEmpty(0, 1);
			player.y += 100;
			playerY += 1;
			if(!checkSuccess())
				grid[playerY][playerX] = 1;
		}

		// up
		else if (direction == "up" && playerY-1 >= 0 && grid[playerY-1][playerX] != 3) {
			visitedOrEmpty(0, -1);
			player.y -= 100;
			playerY -= 1;
			if(!checkSuccess())
				grid[playerY][playerX] = 1;
		}

		// get rid of the original white space that is there before the player moves
		if (firstMove == true) {
			var space = new FlxSprite(0, 500);
			space.makeGraphic(100, 100, FlxColor.WHITE); // currently white, change after
			space.solid = true;
			empties.add(space);
			firstMove = false;
		}

	}

	// function used to solve maze. no particular algorithm used here, although I could have used any pathfinding algorithm e.g. djikstra's
	// this algorithm will likely only work in this case
	// feel that this was all that was necessary for this small program
	public function solveMaze() {

		while (grid[playerY][playerX] != 2) {

			// we will mark already visited blocks as 4 in the grid

			// check if we can move left
			if (playerX-1 >= 0 && grid[playerY][playerX-1] != 3 && grid[playerY][playerX-1] != 4) {
				moveBlock("left");
			}

			// check if we can move right
			else if (playerX+1 <= 5 && grid[playerY][playerX+1] != 3 && grid[playerY][playerX+1] != 4) {
				moveBlock("right");
			}

			// check if we can move up
			else if (playerY-1 >= 0 && grid[playerY-1][playerX] != 3 && grid[playerY-1][playerX] != 4) {
				moveBlock("up");
			}

			// check if we can move down
			else if (playerY+1 <= 5 && grid[playerY+1][playerX] != 3 && grid[playerY+1][playerX] != 4) {
				moveBlock("down");
			}

		}

	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		// define player movement
		if (FlxG.keys.justPressed.LEFT){
			moveBlock("left");
		}
		if (FlxG.keys.justPressed.RIGHT){
			moveBlock("right");
		}
		if (FlxG.keys.justPressed.UP){
			moveBlock("up");
		}
		if (FlxG.keys.justPressed.DOWN){
			moveBlock("down");
		}

		// press space bar to solve
		if(FlxG.keys.justPressed.SPACE) {
			solveMaze();
		}

		if (checkSuccess())
			success();
	}
}
