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

import numpy as np

#Global Variables
MEMORY_AVAILABLE = 32512
lineNum = 0
failed = False
errors = 0
warnings = 0
programOffset = 0

#Opcode
class Opcode:
    def __init__(self, name, argCount, width = -2, ramW = False):
        self.name = name
        self.args = argCount
        if width == -2:
            self.width = argCount * 2
        else:
            self.width = width
        
        self.ramWrite = ramW #These are opcodes that write to RAM depending on half mode
                             #Things like GDTx and CPYx are not included as these are half mode independent
            
class Var:
    def __init__(self, name, initialValue, width, address = -1, atf = True):
        self.name = name
        self.val = initialValue
        self.addr = address
        self.addToFile = atf
        self.width = width

class Alias:
    def __init__(self, name, address):
        self.name = name
        self.addr = address
        
#Opcode list
opcodes = [Opcode("NXI", 0), Opcode("LDA", 1), Opcode("LDAI", 1, -1), Opcode("RDA", 1, ramW = True), Opcode("ATB", 0), Opcode("ATC", 0), Opcode("ATD", 0), 
           Opcode("LDD", 1), Opcode("LDDI", 1, -1), Opcode("BTA", 0), Opcode("CTA", 0), Opcode("ADD", 1), Opcode("SUB", 1), Opcode("MUL", 1), 
           Opcode("LSHFT", 0), Opcode("RSHFT", 0), Opcode("AND", 1), Opcode("OR", 1), Opcode("XOR", 1), Opcode("NOT", 0), Opcode("ADDI", 1, -1), 
           Opcode("SUBI", 1, -1), Opcode("MULI", 1, -1), Opcode("ANDI", 1, -1), Opcode("ORI", 1, -1), Opcode("XORI", 1, -1), Opcode("ANDB", 1), Opcode("ORB", 1), 
           Opcode("XORB", 1), Opcode("NOTB", 0), Opcode("ANDBI", 1, -1), Opcode("ORBI", 1, -1), Opcode("XORBI", 1, -1), Opcode("JMP", 1), Opcode("JPZ", 1), 
           Opcode("JPC", 1), Opcode("BCD", 0), Opcode("CPY", 2), Opcode("CPY2", 2), Opcode("GPU", 0), Opcode("GDT3", 3, 5), Opcode("GDT7", 7, 10), 
           Opcode("SMT", 0), Opcode("SUT", 0), Opcode("WMT", 0), Opcode("WUT", 0), Opcode("WFT", 0), Opcode("WGPU", 0), Opcode("SHM", 0), 
           Opcode("SFM", 0), Opcode("HLT", 0), Opcode("JPG", 1), Opcode("JPL", 1), Opcode("JPE", 1)]

gpuOpcodes = ["gNXI", "gLDC", "gLDI", "gSDC", "gLMV", "gMM2", "gMM4", 
        "gDRL", "gDRP", "gMA2", "gSCO", "gSCI", "gINI", "gSNF", "gCPY"]
        
gpuArgWidths = [2,2,2,1,1,1] ##Ignores first byte

#Functions
def error(msg):
    global failed
    global errors
    failed = True
    print(msg)
    errors += 1

def warning(msg):
    global warnings
    print(msg)
    warnings += 1

def fp16ToHex(fp16):
    return hex(np.float16(fp16).view('H'))[2:].zfill(4)
    
def int16ToHex(i16, line = "UNKNOWN"):
    if i16 > 65535:
        error("ERROR: Value too large on line: " + line)
        return "FFFF"
    else:
        return hex(i16)[2:].zfill(4)

def int8ToHex(i8, line = "UNKNOWN"):
    if i8 > 255:
        error("ERROR: Value too large on line: " + line)
        return "FF"
    else:
        return hex(i8)[2:].zfill(2)

def printList(list):
    for line in list:
        print(line)
    print()
    
def extractOperation(line):
    op = ""
    for char in line:
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

def scanForArguments(text, exptLength, opname):
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
            error("ERROR: Invalid number of parameters for " + opname + " (expected " + str(exptLength) + ", got " + str(len(args)) + ") on line " + str(lineNum))
        
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
                error("ERROR: Cannot parse binary string on line " + line)
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
                error("ERROR: Cannot parse hex string on line " + line)
        else:
            try:
                if half:
                    byteData.append(int8ToHex(int(arg), line))
                else:
                    integerData = int16ToHex(int(arg), line)
                    byteData.append(integerData[2:4])
                    byteData.append(integerData[0:2])
            except:
                error("ERROR: Cannot parse integer on line " + line)
    else:
        try:
            floatData = fp16ToHex(float(arg))
        except:
            error("ERROR: Cannot parse float on line " + line)
            
        byteData.append(floatData[2:4])
        byteData.append(floatData[0:2])
        
    return byteData
    
def varHalfError(opcds, name, line, half):
    if opcds.width == -1 and half:
        error("ERROR: Variable (" + name + ") address illegally accessed during half mode operation on line " + str(line))
  
#Intro
print(""" 
This is an assembler for the SR-1 SoC.
For assembly parameters use a single space between each one and the filename
Assembler debug mode: -db
No File Output mode : -nfo
Print Hex block     : -hx
""")

#File operations
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
    
    assmFilename = filename.replace(".sa", ".mi")
    filename = progRoot + filename
    assmFilename = assmRoot + assmFilename
    
    try:
        progFile = open(filename, 'r')
        if not noFileOut:
            assmFile = open(assmFilename, 'w')
        enteredFile = True
    except:
        print("ERROR: INVALID FILENAME") #Not a failure error, so normal print used

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
             Var("MM_DD4", "0", 1, 32740, False),
             Var("MM_DD3", "0", 1, 32739, False), #Bit masks omitted as useless
             Var("MM_DD2", "0", 1, 32738, False),
             Var("MM_DD1", "0", 1, 32737, False),
             Var("MM_DD0", "0", 1, 32736, False),
             Var("MM_LEDS", "0", 1, 32735, False),
             Var("CONST_ZERO", "0", 1, 0, False)]

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
                    aliases.append(Alias(arg, len(firstPass) - (width + 1)))
                else:
                    error("ERROR: Alias (or variable) " + arg + " already exists")

            elif inVars(arg, variables) != -1 :
                if debug:
                    print("Found reference to (" + arg + ") on line " + str(lineNum))
                firstPass.append('v:' + arg)
                firstPass.append("^^^")
                varHalfError(opInstruction, arg, lineNum, halfMode)

            else:
                if debug:
                    print("Found reference to possible variable (" + arg + ") on line " + str(lineNum))
                firstPass.append('v:' + arg)
                firstPass.append("^^^")
                varHalfError(opInstruction, arg, lineNum, halfMode)
                
    elif operation[:3] == "VAR":
        args = scanForArguments(line, 2, "VAR")
        
        try:
            newVar = Var(args[0], args[1], int(operation[3]))
            if inVars(newVar.name, variables) == -1 and inAliases(newVar.name, aliases) == -1:
                variables.append(newVar)
            else:
                error("ERROR: Variable (or alias) " + newVar.name + " already exists")
            
            if int(operation[3]) == 1 and "." in args[1]:
                error("ERROR: Floating point value assigned to single byte for variable " + newVar.name)
                
            if int(operation[3]) > 2:
                error("ERROR: Size too large for variable " + newVar.name)
        except:
            error("ERROR: Cannot read size for variable on line " + str(lineNum))
        
        if debug:
            print("Found variable declaration (" + args[0] + ") on line " + str(lineNum))
    elif operation.replace(" ", "") == "":
        continue
    else:
        error("ERROR: Operation (" + operation + ") not recognised on line " + str(lineNum))

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
        v.val = numToHex(v.val, (v.width == 1), "VARIABLE CHECK")
    except:
        error("ERROR: Cannot parse initial value (" + v.val + ") for variable " + v.name)
    
    if v.addr == -1:
        v.addr = int16ToHex(progLength + 1)
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
        
            if not halfMode and var.width == 1 and opcodes[lastOpIndex].ramWrite:
                error("ERROR: Half width variable (" + var.name + ") has illegal write attempt during full mode operation")
        else:
            error("ERROR: Unknown variable (" + line + ") found during second pass")

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
            error("ERROR: Cannot parse alias (" + line + ") or offset during second pass")
        
        aliasIndex = inAliases(aliasName, aliases)
        
        if aliasIndex != -1:
            a = aliases[aliasIndex]
        else:
            error("ERROR: Unknown alias (" + aliasName + ") found during second pass")

        addressData = int16ToHex(a.addr + argOffset, "SECOND PASS")
        secondPass.append(addressData[2:4])
        secondPass.append(addressData[0:2])
    elif line == "^^^":
        continue
    elif opIndex != -1:
        secondPass.append(int8ToHex(opIndex))
        
        if line == "SHM":
            halfMode = True
        elif line == "SFM":
            halfMode = False
            
        lastOpIndex = opIndex
    elif line[0] == 'g':
        secondPass.append(int8ToHex(gpuOpcodes.index(line)))
    else:
        secondPass.append(line)
        
for v in variables:
    if v.addToFile:
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
    thirdPass.append(hex(iteration).replace("0x", "") + ":" + line);
        
if debug:
    print("Third Pass Results:")
    printList(thirdPass)

print() #Separate sections

if len(thirdPass) > MEMORY_AVAILABLE:
    error("ERROR: Not enough RAM")
  
if failed:
    print("Assembly Failure (" + str(errors) + " error" + ("s" if errors > 1 else "") + ", " + str(warnings) + " warning" + ("s" if warnings > 1 else "") + ")")
else:
    print("Assembled Successfully\nProgram Size: " + str(progLength) + "B")
    if warnings > 0:
        print("WARNING: This program has " + str(warnings) + " warning" + ("s" if warnings > 1 else ""))
    print("Used " + str(round(100 * (progLength + 1) / MEMORY_AVAILABLE, 2)) + "% of available memory")
    
    if noFileOut:
        print("No File Output mode on, nothing saved")
    else:
        print("Saving at: " + assmFilename)
        
        for line in thirdPass:
            assmFile.write(line + "\n");
            
    if printBlock:
        text = ""
        for ln in secondPass:
            text += ln
        print("Hexadecimal block:\n" + text)
        
print() #Separate sections