
"""
2:0/next_alternative_id = 3
2:0/0 = 0
2:0/1 = 1
2:0/1/flip_h = true
2:0/1/flip_v = true
2:0/1/transpose = true
2:0/1/modulate = Color(0, 0, 0, 1)
2:0/2 = 2
2:0/2/flip_h = true
2:0/2/flip_v = true
2:0/2/transpose = true
2:0/2/modulate = Color(0, 0, 0, 1)
"""

"""
0:0/0 = 0
1:0/0 = 0
2:0/0 = 0
3:0/0 = 0
4:0/0 = 0
5:0/0 = 0
"""

from enum import Enum

colorGradient = [letter * 2 for letter in "fedcba9876543210"]
# Transform color gradient into list of RGB values
colorGradient = [(val, val, val, 1) for val in [round(int(grad, 16) / 255.0, 6) for grad in colorGradient]]

class Tile:
    def __init__(self, coord: str, gradient: list, prefix: str = "") -> None:
        self.gradient = gradient
        self.coord = coord
        self.nextID = 1
        self.output = ""
        self.prefix = prefix
        self.generateTiles()
    
    def generateGradient(self, HFlip: bool, VFlip: bool, Transp: bool):
        def genTile(tileID: int, HFlip: bool, VFlip: bool, Transp: bool):
            prefix = self.coord + "/" + str(tileID)
            tileStr = prefix + " = " + str(tileID) + "\n"
            if HFlip:
                tileStr += prefix + "/flip_h = true\n"
            if VFlip:
                tileStr += prefix + "/flip_v = true\n"
            if Transp:
                tileStr += prefix + "/transpose = true\n"
            return tileStr
        if len(self.gradient) == 0:
            if not Transp and not HFlip and not VFlip:
                return
            self.output += genTile(self.nextID, HFlip, VFlip, Transp)
            self.nextID += 1
            return
        newGrad = self.gradient.copy()
        if not Transp and not HFlip and not VFlip:
            newGrad.remove(newGrad[0])
        for g in newGrad:
            newTile = genTile(self.nextID, HFlip, VFlip, Transp)
            newTile += self.coord + "/" + str(self.nextID) + "/modulate = Color" + str(g) + "\n"
            self.output += newTile
            self.nextID += 1

    def generateTiles(self):
        prefix = self.coord + "/" + str(self.nextID)
        self.output += self.coord + "/0 = 0\n"
        self.generateGradient(False, False, False)
        self.generateGradient(True, False, True)
        self.generateGradient(True, True, False)
        self.generateGradient(False, True, True)
        if self.nextID > 1:
            self.output = self.coord + "/next_alternative_id = " + str(self.nextID) + "\n" + self.output
        if self.prefix != "":
            self.output = "\n" + self.prefix + "\n" + self.output
        

wirePrefix = """[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_axpav"]\nresource_name = "Wires"\ntexture = ExtResource("2_ogsdc")"""
wires = [
    Tile("0:0", colorGradient, wirePrefix), 
    Tile("1:0", colorGradient),
    Tile("2:0", colorGradient), 
    Tile("3:0", colorGradient), 
    Tile("4:0", colorGradient), 
    Tile("5:0", colorGradient)
            ]

machinePrefix = """[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_jnekc"]\nresource_name = "BaseObjs"\ntexture = ExtResource("1_7l41x")"""
machines = [
    Tile("0:0", [], machinePrefix),
    Tile("1:0", []),
    Tile("2:0", []),
    Tile("3:0", []),
    Tile("0:1", []),
    Tile("1:1", []),
    Tile("0:2", []),
    Tile("0:3", []),
    Tile("1:3", [])
            ]

machineWirePrefix = """[sub_resource type="TileSetAtlasSource" id="TileSetAtlasSource_0jiu0"]\nresource_name = "RedstoneObjs"\ntexture = ExtResource("3_01bpq")"""
machineWires = [
    Tile("0:0", colorGradient, machineWirePrefix),
    Tile("1:0", colorGradient),
    Tile("0:1", colorGradient),
    Tile("1:1", colorGradient),
    Tile("2:1", colorGradient),
    Tile("3:1", colorGradient),
    Tile("0:2", colorGradient),
    Tile("1:2", colorGradient),
    Tile("0:3", colorGradient),
    Tile("0:4", [])
]

total = "".join([entry.output for entry in machines + wires + machineWires])
# Save it in a file
with open("gradient.txt", "w") as f:
    f.write(total)