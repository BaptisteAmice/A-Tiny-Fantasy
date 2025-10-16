# Cheatsheet

## Pixel art

### Flou pixel
Canvas Item/Texture/Filter: Set it to Nearest.

## Multiplayer
https://www.reddit.com/r/godot/comments/1lt0wdc/online_coopmultiplayer_guide_for_beginners_beyond/
### Run only on server
```
if not multiplayer.is_server() # do nothing
```

### Run only if is the multiplayer authority of the node
```
# called before ready
func _enter_tree(): set_multiplayer_authority(int(str(name)))
```
```
if !is_multiplayer_authority(): return
```

### Nodes
- MultiplayerSynchronizer: synchro given things, child of player, tell which property to sync (position, player_name, AnimationHandler:frame,AnimationHandler:animation)
- MultiplayerSpawner: tell if something spawn

Note: the MultiplayerSpawner always spawns stuff at origin. This is fine for the level, but not if you want to spawn players at particular spawn points. The way to solve this is instead of running spawn_func(player_position), do:
$MultiplayerSpawner.spawn_function = spawn_func
$MultiplayerSpawner.spawn(player_position) # run on serve
