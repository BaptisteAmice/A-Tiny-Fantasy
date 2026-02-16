# TODO

- les item doivent etre drop coté serveur puis syncrho sur les clients

-----

add pause state to characters
-> no player => no movements


use tilemap terrain autotile
create terrain set
match cohnerner and sizes
paint property paint terrain
only acticvate concerned tiles
https://jackie-codes.itch.io/paradise-asset-pack -> tileset

audio musics
https://www.youtube.com/watch?v=spBakIGn55E

audio sound effects


global rng with one global seed in Global
global class SignalBus : for signals from really different places
global script: Refs.gd with export values that need to be set in editor (icons, colors, etc.) @export_group @export

terrrains
peut etre besoin d'un plugin pour connecter differents terrains
https://www.reddit.com/r/godot/comments/11xtn2i/godot_4_tilemaps_how_can_i_get_different_terrains/
https://github.com/Portponky/better-terrain
https://www.youtube.com/watch?v=0ia6yOKKiGg -> code examples

terrain generation (maybe)
- pass 1: biomes determination, creates x biomes limits with each their custom rules (min/max size), including fixed biomes like spawn area
- pass 2: custom generation passes per biome
- pass next+1 : cutom strucuture generation per biome 


font
https://somepx.itch.io/humble-fonts-gold


logique tuyaux
- un objet avec un inventory peu avoir une liste de target inventories avec un débit d'item/seconde
- les tuyaux servent juste à update cette liste de target inventories
- un ensemble de tuyaux a un inventaire commun -> avec n entrées et m sorties
- besoin tuyaux special pour input/output


add minimap that can be extended



plant growth
https://youtu.be/lGb4M4aSYZs


syncrhonize pickup (dropped item)


------
Note that requesting a coroutine's return value without await will trigger an error:

func wrong():
	var confirmed = wait_confirmation() # Will give an error.

todo : metttre valeur de retour sur toutes mes coroutines
