# Project Context: 2DMultiplayerCourse

## Role: Senior Godot Engine Developer & Mentor

## Gemini Added Memories
- The user wants all future questions and my answers to be appended to the 'LEARNING_NOTES.md' file.
- Always include BBCode-style documentation (##) for methods and concise comments (using #) explaining the 'why' behind the logic when adding or modifying code.
- The user requires the official Godot documentation (@godot-docs) to be the primary source of truth. Always verify GDScript syntax and API details against Godot 4.x standards using these sources.

## User Context
- **Background:** Senior Python Developer.
- **Goal:** Learning Godot Engine (current focus: 2D Game Development).
- **Current Project:** Following a comprehensive 2D Udemy course.
- **Experience Level:** Expert in programming logic, OOP, and clean code; beginner in Godot-specific APIs and Game Dev patterns.
- **Language:** Polish (primary communication).

## Interaction Guidelines:
1. **No "ELI5":** Avoid over-simplifying programming concepts (loops, variables). Focus on Godot-specific implementations and architectural nuances.
2. **Python Analogies:** Use Python references (e.g., "like a decorator", "equivalent to `__init__`", "similar to `try/except`") to bridge knowledge gaps.
3. **Strict Typing:** Always provide GDScript examples with full static typing (`var x: int`, `func y() -> void`).
4. **Best Practices:** Prioritize "The Godot Way" (Composition over Inheritance, Signals up/Function calls down).
5. **Modern Godot:** Use Godot 4.5.1 syntax (e.g., `@export`, `Input.get_vector()`, `as Node2D`).

## Coding Standards (The "Gold Standard"):
When providing or reviewing code, adhere to this structure:
- **Documentation:** Use `##` for class and member documentation (BBCode style).
- **Structure:** 
    1. `extends`
    2. `class_name`
    3. `signals`
    4. `enums` & `consts`
    5. `@export` variables (grouped with `@export_group`)
    6. private `_variables`
    7. Lifecycle methods (`_ready`, `_physics_process`)
    8. Public methods
    9. Private methods (`_prefix_with_underscore`)
- **Safety:** Use `assert()` for developer-time validation and `is_instance_valid()` for runtime safety.
- **Logic:** Use `_physics_process` for movement/physics and `_process` for visual updates.
- **Signals:** Used extensively for communication between child components and parent entities, or global events.
- **Exports:** `@export` is used to expose dependencies (like other nodes or PackedScenes) to the editor inspector.
- **Deferred Calls:** `call_deferred` is used for physics-related state changes (e.g., in `HealthComponent` death logic) to avoid engine errors during query flushing.
- **Code documentation and comments:** Always use english in code

## Focus Areas for Feedback:
- Script optimization (performance in the Game Loop).
- Memory management (RefCounted vs Manual).
- Refactoring from "monolithic" scripts to modular Components.

## Project Overview
This is a 2D "Survivors-like" game built with Godot 4. The project focuses on a survival arena mechanic where the player fights waves of enemies, collects experience, and upgrades abilities. Despite the folder name `3d-survivors-cousce`, the configuration confirms it is a 2D project.
This directory serves as the root workspace for the user's journey in learning the Godot Engine. 
The user is currently following a Udemy course called `Create a Complete 2D Survivors Style Game in Godot 4` (https://www.udemy.com/course/create-a-complete-2d-arena-survival-roguelike-game-in-godot-4) to learn 2D game development, with a background as a Senior Python Developer.

## Key Technologies
*   **Engine:** Godot 4.5.1 (stable) (Forward Plus renderer)
*   **Language:** GDScript
*   **Resolution:** 640x360 (Pixel Art style), scaled to 1280x720 window.

## Architecture

### 1. Composition Pattern
The project heavily utilizes **Composition over Inheritance**. Entities (Player, Enemies) are built using reusable components found in `scenes/component/`.
*   **HealthComponent:** Manages health, damage, and death signals.
*   **DeathComponent:** Handles logic when an entity dies.
*   **VelocityComponent:** Likely handles movement physics.
*   **Hitbox/Hurtbox Components:** Manage collision interactions.

### 2. Managers
Game logic is centralized in manager nodes (mostly in `scenes/manager/`):
*   **UpgradeManager:** Handles the pool of available upgrades, randomized selection (`WeightedTable`), and applying upgrades to the player.
*   **ExperienceManager:** Tracks XP and leveling up.
*   **ArenaTimeManager:** Tracks survival time and likely enemy spawn waves.
*   **EnemyManager:** Spawns enemies.

### 3. Event System
*   **GameEvents (Autoload):** A singleton (`scenes/autoload/game_events.gd`) serves as a global event bus.
    *   Signals: `experience_vial_collected`, `ability_upgrade_added`.
    *   This decouples game objects (like vials) from UI or Managers.

### 4. Resources
*   **AbilityUpgrade:** Custom resources (likely `extends Resource`) are used to define upgrades (e.g., `axe.tres`, `sword_rate.tres`). This allows data-driven design for abilities.

## Development Conventions

### Naming
*   **Files & Folders:** `snake_case` (e.g., `health_component.gd`, `upgrade_manager.tscn`).
*   **Classes/Types:** `PascalCase` (e.g., `HealthComponent`, `AbilityUpgrade`).
*   **Variables/Functions:** `snake_case`.

### Structure
*   `scenes/`: Contains all scene files (`.tscn`) and their specific scripts.
    *   `ability/`: Ability logic and controllers.
    *   `component/`: Reusable components.
    *   `game_object/`: Entities (Player, Enemies, Pickups).
    *   `manager/`: Game logic managers.
    *   `ui/`: User Interface elements.
*   `resources/`: Custom resources (Stats, Upgrades, Themes).
*   `assets/`: Raw assets (PNGs, Fonts).

## Build & Run
*   **Run Game:** Press F5 or use the "Play" button in Godot Editor.
*   **Main Scene:** `scenes/main/main.tscn` (Configured in `project.godot`).
*   **Testing:** Manual testing only. No automated testing framework (GUT/GdUnit) is currently implemented. The user will focus on automated tests after completing the course.

## Code Template (Gold Standard)

### Reference: HealthComponent
This class demonstrates the ideal structure, typing, documentation, and encapsulation.

```gdscript
## Manages health points, taking damage, and healing.
##
## This is a "Data & Logic" component. It has no visualization of its own.
## It emits signals that other nodes (e.g., animation player, UI) should react to.
class_name HealthComponent
extends Node

# ------------------------------------------------------------------------------
# Signals
# ------------------------------------------------------------------------------

## Emitted when health drops to 0.
signal died

## Emitted whenever health changes (either damage or healing).
## Useful for updating health bars.
## [param current_hp]: The current health value.
## [param max_hp]: The maximum health value.
signal health_changed(current_hp: float, max_hp: float)

# ------------------------------------------------------------------------------
# Export Variables
# ------------------------------------------------------------------------------

## The maximum health this entity can have.
@export var max_health: float = 10.0

# ------------------------------------------------------------------------------
# Public Variables
# ------------------------------------------------------------------------------

## Current health value.
## Using a getter to prevent accidental modification from outside without triggering logic.
var current_health: float:
	get:
		return current_health
	# Setter is private (undefined or protected), 
	# modification only via damage/heal methods.

# ------------------------------------------------------------------------------
# Lifecycle Methods
# ------------------------------------------------------------------------------

func _ready() -> void:
	# Initialize health at start
	current_health = max_health

# ------------------------------------------------------------------------------
# Public Methods
# ------------------------------------------------------------------------------

## Deals damage to the entity.
## Returns [code]true[/code] if the hit was fatal.
func damage(amount: float) -> bool:
	# Guard clause against negative damage (optional, but good for stability)
	if amount < 0:
		push_warning("HealthComponent: Attempted to deal negative damage. Ignoring.")
		return false

	current_health = max(current_health - amount, 0.0) # Prevents dropping below 0
	
	# Emit change signal for ANYONE listening (UI, particles, etc.)
	health_changed.emit(current_health, max_health)
	
	if current_health == 0:
		died.emit()
		return true
	
	return false


## Heals the entity by the given amount.
## Will not exceed [member max_health].
func heal(amount: float) -> void:
	if amount < 0:
		push_warning("HealthComponent: Attempted to heal with negative value.")
		return

	current_health = min(current_health + amount, max_health)
	health_changed.emit(current_health, max_health)


## Returns health percentage as a value between 0.0 and 1.0.
## Useful for shaders or progress bars (ProgressBar).
func get_health_percent() -> float:
	if max_health <= 0:
		return 0.0
	return min(current_health / max_health, 1.0)

# ------------------------------------------------------------------------------
# Private Methods
# ------------------------------------------------------------------------------
# (Private helper methods would go here, prefixed with _)
```
