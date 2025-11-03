# TODO

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
scene changer: add a quick animation https://youtu.be/KOI0y1OC_tM?t=535



terrain generation (maybe)
- pass 1: biomes determination, creates x biomes limits with each their custom rules (min/max size), including fixed biomes like spawn area
- pass 2: custom generation passes per biome
- pass next+1 : cutom strucuture generation per biome 
