# Simple assembler version 2.0.4
# Assembles simple assembly files into machine code
# into a .mi file needed by the Gowin bsram init menu.
# RAM settings:
# Name: DP_BSRAM8
# Language: Verilog
# Address_depth = 32768 (both)
# Data width = 8 (both)
# Read mode = Bypass
# Write mode = Normal
# Then select your generated mi file
#
# Copyright © 2025 Stanley Booth - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the CC BY-NC 4.0 license

import os
import sys
import numpy as np

#Global Variables
MEMORY_AVAILABLE = 32512
lineNum = 0
failed = False
errors = 0
warnings = 0
programOffset = 0
showReadConfig = False #For config debug purposes

#Opcode
class Opcode:
    def __init__(self, argArray): #name, argCount, width = -2, ramW = False
        self.name = argArray[0]
        self.index = int(argArray[1])
        self.args = int(argArray[2])
        if argArray[3] == "V":
            self.width = -1
        else:
            self.width = int(argArray[3])
        
        self.ramWrite = (argArray[4] == "T")    #These are opcodes that write to RAM depending on half mode
                                                #Things like GDTx and CPYx are not included as these are half mode independent
    
    def show(self):
        opcodeText = "OPCODE - NAME:" + self.name.ljust(5) + " INDEX:" + str(self.index).ljust(3) + " REQUIRED ARGS:" + str(self.args).ljust(1) + " WIDTH:"
        
        if (self.width == -1):
            opcodeText += "VARIABLE"
        else:
            opcodeText += str(self.width).ljust(8)
        
        opcodeText += " VARIABLE WIDTH RAM WRITE:"
        
        if self.ramWrite:
            opcodeText += "TRUE "
        else:
            opcodeText += "FALSE"
        
        print(opcodeText)
            
class Var:
    def __init__(self, name, initialValue, width, address = -1, atf = True, buffer = False):
        self.name = name
        self.val = initialValue
        self.addr = address
        self.addToFile = atf
        self.width = width
        self.buffer = buffer

class Alias:
    def __init__(self, name, address):
        self.name = name
        self.addr = address
        
#Configuration
opcodes = [] #In config file
configFiles = {}
mostRecentConfigVersion = 0
configFolderPath = "Config"
versionExpandConstant = 10000 #Allows versions up to like so XXXX.YYYY.ZZZZ
gpuOpcodes = ["gNXI", "gLDC", "gLDI", "gSDC", "gLMV", "gMM2", "gMM4", 
        "gDRL", "gDRP", "gMA2", "gSCO", "gSCI", "gINI", "gSNF", "gCPY"] #Will be added to config file later
        
gpuArgWidths = [2,2,2,1,1,1] ##Ignores first byte

#Functions
def error(msg):
    global failed
    global errors
    failed = True
    print("ERROR: " + msg)
    errors += 1

def warning(msg):
    global warnings
    print(msg)
    warnings += 1

def fp16ToHex(fp16):
    return hex(np.float16(fp16).view('H'))[2:].zfill(4)
    
def int16ToHex(i16, line = "UNKNOWN"):
    if i16 > 65535:
        error("Value too large on line: " + line)
        return "FFFF"
    else:
        return hex(i16)[2:].zfill(4)

def int8ToHex(i8, line = "UNKNOWN"):
    if i8 > 255:
        error("Value too large on line: " + line)
        return "FF"
    else:
        return hex(i8)[2:].zfill(2)

def printList(list):
    for line in list:
        print(line)
    print()
    
def extractOperation(line):
    op = ""
    for char in line.lstrip():
        if (char != ' ') and (char != '\n') and (char != '/'):
            op = op + char
        else:
            break
    return op

def inOpcodes(name):
    index = 0
    for opcode in opcodes:
        if opcode.name == name:
            return index
        index += 1
    return -1
    
def inVars(name, variables):
    index = 0
    for v in variables:
        if v.name == name:
            return index
        index += 1
    return -1
    
def inAliases(name, aliases):
    index = 0
    for a in aliases:
        if a.name == name:
            return index
        index += 1
    return -1

def scanForArguments(text, exptLength, opname, includeLine = True):
    args = []
    firstSpaceFound = False
    arg = ""
    for c in text:
        if firstSpaceFound:
            if c == ' ':
                arg = arg.strip()
                if arg != '':
                    args.append(arg)
                arg = ''
            elif c != '/' and c != '\n':
                arg += c
            else: #Breaks when a comment or newline is detected (//)
                arg = arg.strip()
                if arg != '':
                    args.append(arg)
                break
        elif c == ' ':
            firstSpaceFound = True
    
    argsLength = len(args)
    
    if argsLength != exptLength:
        if not (argsLength == exptLength + 1 and (args[argsLength - 1][0] == '(' and args[argsLength - 1][len(args[argsLength - 1]) - 1] == ')')):
            errorMsg = "Invalid number of parameters for " + opname + " (expected " + str(exptLength) + ", got " + str(len(args)) + ")"
            
            if includeLine:
                errorMsg += "on line " + str(lineNum)
                
            error(errorMsg)
        
    return args
    
def numToHex(arg, half, line):
    byteData = []
    
    if "." not in arg:
        if arg[0:2] == "0b":
            try:
                arg = arg[2:]
                num = int(arg, 2)
                if half:
                    byteData.append(int8ToHex(num, line))
                else:
                    integerData = int16ToHex(num, line)
                    byteData.append(integerData[2:4])
                    byteData.append(integerData[0:2])
            except:
                error("Cannot parse binary string on line " + line)
        elif arg[0:2] == "0x":
            try:
                arg = arg[2:]
                num = int(arg, 16)
                if half:
                    byteData.append(int8ToHex(num, line))
                else:
                    integerData = int16ToHex(num, line)
                    byteData.append(integerData[2:4])
                    byteData.append(integerData[0:2])
            except:
                error("Cannot parse hex string on line " + line)
        else:
            try:
                if half:
                    byteData.append(int8ToHex(int(arg), line))
                else:
                    integerData = int16ToHex(int(arg), line)
                    byteData.append(integerData[2:4])
                    byteData.append(integerData[0:2])
            except:
                error("Cannot parse integer on line " + line)
    else:
        try:
            floatData = fp16ToHex(float(arg))
        except:
            error("Cannot parse float on line " + line)
            
        byteData.append(floatData[2:4])
        byteData.append(floatData[0:2])
        
    return byteData
    
def varHalfError(opcds, name, line, half):
    if opcds.width == -1 and half:
        error("Variable (" + name + ") address illegally accessed during half mode operation on line " + str(line))

def versionToNum(versionString):
    versionSections = scanForArguments(" " + versionString.replace(".", " ") + " ", 3, "VERSION", False)
    num = int(versionSections[0]) * versionExpandConstant * versionExpandConstant
    num += int(versionSections[1]) * versionExpandConstant
    num += int(versionSections[2])  
    return num

def numToVersion(versionNum):
    string = ""
    string += str(int(versionNum / (versionExpandConstant * versionExpandConstant))) + "."
    string += str(int(str(int(versionNum / versionExpandConstant))[-4:])) + "."
    string += str(int(str(int(versionNum))[-4:]))
    return string

def findConfigs(): #Finds all config files
    global failed
    global mostRecentConfigVersion
    filenames = []
    
    try:
        for name in os.listdir(configFolderPath):
            if name.endswith(('.acf')):
                filenames.append(name)
    except Exception as e:
        error("Issue with config folder - " + repr(e))
        sys.exit()
        
    for f in filenames:
        file = open(configFolderPath + "/" + f, 'r')
        line = file.readline().strip()

        if line[:7] == "VERSION":
            versionString = extractOperation(line[7:])
            versionSections = scanForArguments(" " + versionString.replace(".", " ") + " ", 3, "VERSION", False)
            try:
                versionNum = versionToNum(versionString)
                
                if versionNum in configFiles:
                    error("Conflicting files with same version (" + f + ") and (" + configFiles[versionNum] + ")")
                else:
                    configFiles[versionNum] = f
                
                if versionNum > mostRecentConfigVersion:
                    mostRecentConfigVersion = versionNum
            except:
                error("Cannot read config version numbers in file (" + f + ")")
                
        else:
            error("Cannot read config version in file (" + f + "). Make sure it is on the first line")
        
        file.close()

    if failed:
        error("Configuration file issue. Aborted")
        sys.exit()
 
def readConfig(filename):
    global failed
    configFile = None
    
    if filename == "":
            error("Cannot find config file (must end in .acf)")
            sys.exit()
    else:
        try:
            configFile = open(configFolderPath + "/" + filename, 'r')
        except:
            error("Cannot open config file")
            sys.exit()
    
    configuration = configFile.readlines()
    configFile.close()
    confLine = 0
    
    for line in configuration:
        confLine += 1
        if confLine > 1:
            configOp = extractOperation(line)
            lineArgs = line.lstrip().replace(configOp, "") + '\n'
            
            if configOp == "OPCODE":
                confArgs = scanForArguments(lineArgs, 5, "CONFIG OPCODE")
                try:
                    newOp = Opcode(confArgs)
                    opcodes.append(newOp)
                    if showReadConfig:
                        newOp.show()
                except:
                    error("Couldn't read opcode arguments on line " + str(confLine))
            elif not configOp == "":
                error("Unrecognised configuration keyword (" + configOp + ") on line " + str(confLine))
            
    if failed:
        error("Configuration file issue. Aborted")
        sys.exit()
  
#Intro
print(""" 
This is an assembler for the SR-1 SoC.
For assembly parameters use a single space between each one and the filename
Assembler debug mode: -db
No File Output mode : -nfo
Print Hex block     : -hx
""")

#Find config files and their versions
findConfigs()

#User File operations
progRoot = "Programs/"
assmRoot = "Assembled/"
enteredFile = False
debug = False
noFileOut = False
printBlock = False

while not enteredFile:
    filename = input("Enter file name: " + progRoot)
    
    if " -db" in filename:
        print("Debug mode enabled")
        debug = True
        filename = filename.replace(" -db", '')
        
    if " -nfo" in filename:
        print("No file output mode enabled")
        noFileOut = True
        filename = filename.replace(" -nfo", '')
    
    if " -hx" in filename:
        print("Print hexadecimal block enabled")
        printBlock = True
        filename = filename.replace(" -hx", '')
    
    if " -v" in filename:
        substring = filename[(filename.find(" -v") + 3):]
        versionText = extractOperation(substring)
        print("Using specified configuration version: " + versionText)
        currentConfig = versionToNum(versionText)
        filename = filename.replace(" -v" + versionText, '')
    else:
        currentConfig = mostRecentConfigVersion

    filename = filename.strip()
    
    assmFilename = filename.replace(".sa", ".mi")
    filename = progRoot + filename
    assmFilename = assmRoot + assmFilename
    
    try:
        progFile = open(filename, 'r')
        enteredFile = True
    except:
        print("ERROR: Invalid filename") #Not a failure error, so normal print used

#Getting configuration
print("Using configuration file: " + configFiles[currentConfig] + "\nVersion: " + numToVersion(currentConfig))
readConfig(configFiles[currentConfig])
print() #Separates sections
       
lines = progFile.readlines()
progFile.close()
firstPass = []
halfMode = False
offsetAddress = 0
aliases = [Alias("RAM_START", 0)]

#Variable list with predefined addresses already added
variables = [Var("MM_CLKPRE", "0", 1, 32767, False),
             Var("MM_GREPEAT", "0", 1, 32766, False),
             Var("MM_GPCBI", "0", 1, 32765, False),
             Var("MM_GPCAI", "0", 1, 32764, False),
             Var("MM_GPCB", "0", 2, 32762, False),
             Var("MM_C2G", "0", 2, 32760, False),
             Var("MM_GPCA", "0", 2, 32758, False),
             Var("MM_GINSTR", "0", 1, 32757, False),
             Var("MM_G2C", "0", 2, 32755, False),
             Var("MM_GFP2I", "0", 2, 32753, False),
             Var("MM_BUTTON", "0", 1, 32752, False),
             Var("MM_WIDE", "0", 2, 32750, False),
             Var("MM_THIN", "0", 1, 32749, False),
             Var("MM_D", "0", 2, 32747, False),
             Var("MM_C", "0", 2, 32745, False),
             Var("MM_B", "0", 2, 32743, False),
             Var("MM_A_H", "0", 1, 32742, False),
             Var("MM_A_L", "0", 1, 32741, False),
             Var("MM_DD4", "0", 1, 32740, False),
             Var("MM_DD3", "0", 1, 32739, False),
             Var("MM_DD2", "0", 1, 32738, False),
             Var("MM_DD1", "0", 1, 32737, False),
             Var("MM_DD0", "0", 1, 32736, False),
             Var("MM_LEDS", "0", 1, 32735, False),
             Var("CONST_ZERO", "0", 2, 0, False)]

programOffset += 1; #First 2 addresses are zero for CONST_ZERO Variable

for line in lines:
    lineNum += 1
    operation = extractOperation(line)
    line = line.replace(operation, "") + '\n' 
    opIndex = inOpcodes(operation)
    
    if opIndex != -1:
        firstPass.append(operation)
        
        opInstruction = opcodes[opIndex]
        width = opInstruction.width
        
        if width == -1:
            if halfMode:
                width = 1
            else:
                width = 2
                
        if opInstruction.name == "SHM":
            halfMode = True
        elif opInstruction.name == "SFM":
            halfMode = False
        
        args = scanForArguments(line, opInstruction.args, opInstruction.name)
        
        gpuOperation = False
        gpuOpIndex = 0
        for arg in args:
            if arg[0] == "*":
                if debug:
                    print("Found reference to possible alias (" + arg + ") on line " + str(lineNum))
                firstPass.append(arg)
                firstPass.append("^^^")   
                
            elif arg.replace(".", "").isnumeric() or arg[0:2] == "0b" or arg[0:2] == "0x":
                firstPass = firstPass + numToHex(arg, ((halfMode and not gpuOperation) or (gpuArgWidths[gpuOpIndex] == 1 and gpuOperation)), str(lineNum))
                gpuOpIndex += 1
                
                if not opInstruction.width == -1 and not gpuOperation:
                    warning("WARNING: Numeric argument for non immediate or GPU operation (" + opInstruction.name + ") on line " + str(lineNum))
                
            elif arg in gpuOpcodes:
                firstPass.append(arg)
                gpuOperation = True
                
            elif arg[0] == '(' and arg[len(arg) - 1] == ')': #Alias declaration
                if debug:
                    print("Found alias (" + arg + ") on line " + str(lineNum))
                
                arg = arg.replace("(", "").replace(")", "")
               
                if inVars(arg, variables) == -1 and inAliases(arg, aliases) == -1:
                    aliases.append(Alias(arg, len(firstPass) - (width + 1) + programOffset))
                else:
                    error("Identifier (" + arg + ") already exists")

            elif inVars(arg, variables) != -1 :
                if debug:
                    print("Found reference to (" + arg + ") on line " + str(lineNum))
                firstPass.append('v:' + arg)
                firstPass.append("^^^")
                varHalfError(opInstruction, arg, lineNum, halfMode)

            else:
                if debug:
                    print("Found reference to possible variable/buffer (" + arg + ") on line " + str(lineNum))
                firstPass.append('v:' + arg)
                firstPass.append("^^^")
                varHalfError(opInstruction, arg, lineNum, halfMode)
                
    elif operation[:3] == "VAR" or operation == "BUF":
        isBuffer = (operation == "BUF")
        args = scanForArguments(line, 2, ("BUFFER" if isBuffer else "VARIABLE"))
        
        try:
            newVar = Var(args[0], 
                (0 if isBuffer else args[1]), 
                (int(args[1]) if isBuffer else int(operation[3])), 
                buffer = isBuffer)
                
            if inVars(newVar.name, variables) == -1 and inAliases(newVar.name, aliases) == -1:
                variables.append(newVar)
            else:
                error("Identifier (" + newVar.name + ") already exists")
            
            if not isBuffer:
                if int(operation[3]) == 1 and "." in args[1]:
                    error("Floating point value assigned to single byte for variable " + newVar.name)
                    
                if int(operation[3]) > 2:
                    error("Size too large for variable " + newVar.name)
        except:
            error("Cannot read size for variable or width of buffer on line " + str(lineNum))
        
        if debug:
            print("Found variable/buffer declaration (" + args[0] + ") on line " + str(lineNum))
    elif operation.replace(" ", "") == "":
        continue
    else:
        error("Operation (" + operation + ") not recognised on line " + str(lineNum))

if debug:
    print("\nFirst Pass Results:")
    printList(firstPass)
        
#Second pass
progLength = len(firstPass)
secondPass = []
halfMode = False
lastOpIndex = 0

for v in variables:   
    try:
        if v.buffer:
            v.val = "00"
        else:
            v.val = numToHex(v.val, (v.width == 1), "VARIABLE CHECK")
    except:
        error("Cannot parse initial value (" + str(v.val) + ") for variable " + v.name)
    
    if v.addr == -1:
        v.addr = int16ToHex(progLength + 1 + programOffset)
        progLength += v.width
    else:
        v.addr = int16ToHex(v.addr, "VARIABLE CHECK")

for line in firstPass:
    opIndex = inOpcodes(line)
    
    if line[0:2] == "v:":
        line = line[2:]
        varIndex = inVars(line, variables)
        if varIndex != -1:
            var = variables[varIndex]
            secondPass.append(var.addr[2:4])
            secondPass.append(var.addr[0:2])
            
            if halfMode and var.width == 2:
                warning("WARNING: Variable (" + var.name + ") is used in half mode operation, but is a 2B value. Only the first byte will be used")
        
            if not halfMode and var.width == 1 and lastOp.ramWrite:
                error("Half width variable (" + var.name + ") has illegal write attempt during full mode operation")
        else:
            error("Unknown variable (" + line + ") found during second pass")

    elif line[0] == '*': #Alias use
        try:
            if "+" in line:
                plusLocation = line.find("+")
                aliasName = line[1:plusLocation]
                argOffset = int(line[plusLocation:]) + 2 #Offsets to first argument by default
            else:
                aliasName = line[1:]
                argOffset = 0
        except:
            error("Cannot parse alias (" + line + ") or offset during second pass")
        
        aliasIndex = inAliases(aliasName, aliases)
        
        if aliasIndex != -1:
            a = aliases[aliasIndex]
        else:
            error("Unknown alias (" + aliasName + ") found during second pass")

        addressData = int16ToHex(a.addr + argOffset, "SECOND PASS")
        secondPass.append(addressData[2:4])
        secondPass.append(addressData[0:2])
    elif line == "^^^":
        continue
    elif opIndex != -1:
        secondPass.append(int8ToHex(opcodes[opIndex].index))
        
        if line == "SHM":
            halfMode = True
        elif line == "SFM":
            halfMode = False
            
        lastOp = opcodes[opIndex]
    elif line[0] == 'g':
        secondPass.append(int8ToHex(gpuOpcodes.index(line)))
    else:
        secondPass.append(line)
        
for v in variables:
    if v.addToFile: 
        if v.buffer:
            buffer = []
            for i in range(0, v.width):
                buffer += ["00"]
            secondPass += buffer
        else:
            secondPass += v.val;
 
if debug:
    print("\nSecond Pass Results:")
    printList(secondPass)
 
#Third pass
progLength = len(secondPass)
iteration = 0
thirdPass = ["#File_format=AddrHex", "#Address_depth=32768", "#Data_width=8"]

for line in secondPass:
    iteration = iteration + 1
    thirdPass.append(hex(iteration + programOffset).replace("0x", "") + ":" + line);
        
if debug:
    print("Third Pass Results:")
    printList(thirdPass)

print() #Separate sections

if len(thirdPass) > MEMORY_AVAILABLE:
    error("Not enough RAM")
  
if failed:
    print("Assembly Failure (" + str(errors) + " error" + ("s" if errors > 1 else "") + ", " + str(warnings) + " warning" + ("s" if warnings > 1 else "") + ")")
    print("Make sure the correct configuration version has been used")
else:
    print("Assembled Successfully\nProgram Size: " + str(progLength) + "B")
    if warnings > 0:
        print("WARNING: This program has " + str(warnings) + " warning" + ("s" if warnings > 1 else ""))
    print("Used " + str(round(100 * (progLength + 1) / MEMORY_AVAILABLE, 2)) + "% of available memory")
    
    if noFileOut:
        print("No File Output mode on, nothing saved")
    else:
        print("Saving at: " + assmFilename)
        assmFile = open(assmFilename, 'w')
        
        for line in thirdPass:
            assmFile.write(line + "\n");
            
    if printBlock:
        text = ""
        for ln in secondPass:
            text += ln
        print("Hexadecimal block:\n" + text)
        
print() #Separate sections