# Project Context: 2DMultiplayerCourse

Legend:

* `Node`: Scene type
* @main.tscn: File path from main catalog
* "Player": Own name, value or parameter

## Lesson 1

1. Create new scene type `Node` as @main.tscn and save it to root folder
2. Add GDScript to @main.tscn with name @main.gd
3. Add simple "Hello World" print to _ready() method in @main.gd

## Lesson 2

1. Create new scene `CharacterBody2D` with name "Player"
2. Save "Player" scene to @entities/player/player.tscn
3. Add Child Node to "Player" as `Sprite2D`
4. Set texture to `Sprite2D` as `PlaceholderTexture2D`
5. Set texture size to x=18.0px, y=32.0px
6. Set `Sprite2D` position to x=0.0px, y=-16.0.px (base at 0x0)
7. Add Child Node to "Player" as `CollisionShape2D`
8. Set `CollisionShape2D` shape to `CircleShape2D` with radius 10.0px
9. Set `CollisionShape2D` position to x=0.0px, y=-10.0px (base at 0x0)
10. In "Main" scene, Instantiate Child Scene of "Player"
11. Set "Player" position in "Main" in the middle of camera view
12. Run project and validate that "Player" is seen

## Lesson 3

1. Add WASD and arrow keys to Input Map as "move_left", "move_right"...
2. Add script to "Player" node:

```gdscript
extends CharacterBody2D


func _process(_delta: float) -> void:
    var movement_vector: Vector2 = Input.get_vector(
        "move_left",
        "move_right",
        "move_up",
        "move_down"
    )
    velocity = movement_vector * 100
    move_and_slide()
```
