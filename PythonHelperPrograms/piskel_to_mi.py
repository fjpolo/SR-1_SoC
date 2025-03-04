# Converts the C file export option (of a black (00000000) and white (ffffffff) image) from https://www.piskelapp.com/ 
# into a .mi file needed by the Gowin bsram init menu.
# Frame Buffer settings:
# Name: DP_BSRAM
# Language: Verilog
# Address_depth = 2048
# Data width = 8
# Read mode = Bypass
# Write mode = Normal
# Then select your generated mi file
#
# Copyright (C) 2025 Stanley Booth - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the CC BY NC license

# !! FOR 128x64 'IMAGES' ONLY !!

xMax = 128
yMax = 64
image = []

for i in range(xMax):
    image.append([])

gettingFile = True
while (gettingFile):
    name = input("Enter the piskel c file: ")
    
    try:
        if (".c" in name):
            file = open(name, "r")
            gettingFile = False
        else:
            print("ERROR: Filename invalid (must be a .c file)\n")
    except:
        print("ERROR: File cannot be found, check the name.\n")

prevChar = ''
sampleNext = False
pixelsFound = 0;
xCoord = 0
yCoord = 0

while 1:
    c = file.read(1)
    
    if (not c):
        break
    
    if (sampleNext):
        xCoord += 1
        
        if (c == '0'):
            image[yCoord].append(0)
        elif (c != '0'):
            image[yCoord].append(1)
            
        if (xCoord == xMax):
            xCoord = 0
            yCoord += 1
        
        pixelsFound += 1;        
        sampleNext = False
        
    elif (prevChar == '0' and c == 'x'):
        sampleNext = True
    
    prevChar = c

file.close()
  
print("\nPixels found: " + str(pixelsFound))
print("Image preview:")

for x in image:
    line = ""
    for pixel in x:
        if(pixel):
            line += "##"
        else:
            line += ".."
    print(line)
    
   
name_init = name.replace(".c", "") + ".mi"
file = open(name_init, "w")
file.write("#File_format=Bin\n#Address_depth=2048\n#Data_width=8\n")

bytesWritten = 0

for i in range(1024): #Filling the first half of the frame buffer with the image
    pixByte = ""
    for y in range (8):
        #print("X: " + str(int(bytesWritten / 8)) + ", Y: " + str((bytesWritten % 8) * 8 + y))
        pixByte += str(image[(bytesWritten % 8) * 8 + (7-y)][int(bytesWritten / 8)])
        
    file.write(pixByte + "\n")
    bytesWritten += 1

for i in range(1024): #Filling the second half of the frame buffer with zeros
    file.write("00000000\n")
file.close()

print("Finished. Data saved in " + name_init)
    