#!/usr/bin/python

import sys
import subprocess
import shutil
import os

from pathlib import Path
from collections import OrderedDict

pyiiasmh = "tools/pyiiasmh/pyiiasmh_cli.py"

'''
Download PyiiASMH from the releases section. Don't clone the repository.

'''

codeName = "Show Lap Splits after a Grand Prix Race [QB22]"
codeDesc = "Shows the player's lap splits after a Grand Prix race."

# 32-Bit Write Values
loadNewPageWrite = "3800002d"
virtFuncOverwrite_initSelf= "800017B4"
virtFuncOverwrite_solveAnimation = "800017b0"
floatWrite = "40440000"

finalOut = "finalOut.txt"

errorCount = 0

def getRegion():
    regionLetter = input("Input the letters P, E, J or K for your region.\n")
    if len(regionLetter) > 1:
            print ("No more than one character can be input. Exiting.\n")
            sys.exit()
    if regionLetter == 'p' or regionLetter == 'P' or regionLetter == 'e' or regionLetter == 'E' or regionLetter == 'j' or regionLetter == 'J' or regionLetter == 'k' or regionLetter == 'K':
        return regionLetter
    else:
        print("Only input the letters, P, E, J, or K. Exiting.")
        sys.exit()

def processRegion(regionLetter):
    if regionLetter == 'p' or regionLetter == 'P':
        region = "RMCP01"
    elif regionLetter == 'e' or regionLetter == 'E':
        region = "RMCE01"
    elif regionLetter == 'j' or regionLetter == 'J':
        region = "RMCJ01"
    elif regionLetter == 'k' or regionLetter == 'k':
        region = "RMCK01"
    else:
        print ("Invalid character(s) entered.")
        sys.exit

    return region

def getWriteAddress(regionLetter):
    # 32-Bit Write Base Addresses
    loadNewPage = "0462473c"
    floatAddress = "048aa044"
    CtrlRaceBase_initSelf_vf = "048d3eb0"
    UIControl_solveAnimation_vf = "048d3eb8"

    # A list of base addresses
    writeAddress = [
        loadNewPage,
        floatAddress,
        CtrlRaceBase_initSelf_vf,
        UIControl_solveAnimation_vf
    ]

    if regionLetter == 'p' or regionLetter == 'P':
        return writeAddress
    elif regionLetter == 'e' or regionLetter == 'E':
        writeAddress[0] = "045f3888" # loadNewPage
        writeAddress[1] = "048a471c" # floatAddress
        writeAddress[2] = "048cef48" # CtrlRaceBase_initSelf_vf
        writeAddress[3] = "048cef50" # UIControl_solveAnimation_vf
    elif regionLetter == 'j' or regionLetter == 'J':
        writeAddress[0] = "04623e88" # loadNewPage
        writeAddress[1] = "048A91A4" # floatAddress
        writeAddress[2] = "048d3000" # CtrlRaceBase_initSelf_vf
        writeAddress[3] = "048d3008" # UIControl_solveAnimation_vf
    elif regionLetter == 'k' or regionLetter == 'K':
        writeAddress[0] = "04612b34" # loadNewPage
        writeAddress[1] = "048984A4" # floatAddress
        writeAddress[2] = "048c2348" # CtrlRaceBase_initSelf_vf
        writeAddress[3] = "048c2350" # UIControl_solveAnimation_vf

    return writeAddress

def getBaseAddress(regionLetter):
    # C2 Base Addresses
    DisableElementsInGP = "80855c24"
    FixTimerAnimation = "807f8800"
    RegisterPage = "8062c5b8"
    FreezePosTracker1 = "800017B4"
    FreezePosTracker2 = "800017B0"
    NoPositionTrackerEntranceAnim = "807f4a20"
    PreventPositionChangeAnim = "807f4b60"
    PreventPositionChangeSFX = "807f4ac4"
    UpdateControlCount = "80855954"
    LoadControl = "80855abc"

    # A list of C2 hooks
    baseAddress = [
        DisableElementsInGP,
        FixTimerAnimation,
        RegisterPage,
        FreezePosTracker1,
        FreezePosTracker2,
        LoadControl,
        NoPositionTrackerEntranceAnim,
        PreventPositionChangeAnim,
        PreventPositionChangeSFX,
        UpdateControlCount
    ]

    list(OrderedDict.fromkeys(baseAddress))

    if regionLetter == 'p' or regionLetter == 'P':
        return baseAddress
    elif regionLetter == 'e' or regionLetter == 'E':
        baseAddress[0] = "80834194"
        baseAddress[1] = "807edd00"
        baseAddress[2] = "805fb704"
        baseAddress[5] = "8083402c"
        baseAddress[6] = "807ea3f8"
        baseAddress[7] = "807ea538"
        baseAddress[8] = "807ea49c"
        baseAddress[9] = "80833ec4"

    elif regionLetter == 'j' or regionLetter == 'J':
        baseAddress[0] = "80855290"
        baseAddress[1] = "807f7e6c"
        baseAddress[2] = "8062bd04"
        baseAddress[5] = "80855128"
        baseAddress[6] = "807f408c"
        baseAddress[7] = "807f41cc"
        baseAddress[8] = "807f4130"
        baseAddress[9] = "80854fc0"

    elif regionLetter == 'k' or regionLetter == 'K':
        baseAddress[0] = "80843fe4"
        baseAddress[1] = "807e6bc0"
        baseAddress[2] = "8061a9b0"
        baseAddress[5] = "80843e7c"
        baseAddress[6] = "807e2de0"
        baseAddress[7] = "807e2f20"
        baseAddress[8] = "807e2e84"
        baseAddress[9] = "80843d14"

    return baseAddress

def assembleFromFile(regionLetter, curDir, addressCycle):
    baseAddress = getBaseAddress(regionLetter)

    # The current working directory is unaware that this file is needed so let's copy it.
    includeFile = "__includes.s"
    shutil.copyfile(f"tools/pyiiasmh/{includeFile}", f"{includeFile}")

    tempCode = "tmp.s"
    asmOut = "asmOut.txt"

    for file in Path(curDir).rglob('*.s'):
        codeFile = f"{curDir}/{file.name}"

        with open(codeFile, 'r') as code, open(tempCode, 'w') as tmp:
            tmp.write(f".set region, '{regionLetter}'\n\n")
            for line in code:
                tmp.write(line)

        print(baseAddress[addressCycle])
        print(file.name)

        subprocess.run(["python", pyiiasmh, tempCode, 'a', '--dest', asmOut, '--codetype', 'C2D2', '--bapo', f'{baseAddress[addressCycle]}'])

        with open(asmOut, 'r') as scratchAssembly, open(finalOut, 'a') as codeOutput:
            for line in scratchAssembly:
                codeOutput.write(line)
            codeOutput.write("\n")

        if addressCycle == 2:
            return
        if addressCycle == 9:
            os.remove(includeFile)
            os.remove(tempCode)
            os.remove(asmOut)
            break

        addressCycle += 1

def assembleASMCode(regionLetter):
    pageDir = "src/Page"
    posTrackerDir = "src/Position_Tracker"

    curDir = pageDir
    addressCycle = 0

    assembleFromFile(regionLetter, curDir, addressCycle)

    curDir = posTrackerDir
    addressCycle = 3

    assembleFromFile(regionLetter, curDir, addressCycle)

def assembleCode(region, regionLetter, writeAddress,):
    with open(f"{region}.txt", 'w') as codeOutput:
        codeOutput.write(f"{region}\n")
        codeOutput.write("Mario Kart Wii\n\n")
        codeOutput.write(f"{codeName}\n")
        codeOutput.write(f"{writeAddress[0]} " f"{loadNewPageWrite}\n")
        codeOutput.write(f"{writeAddress[1]} " f"{floatWrite}\n")
        codeOutput.write(f"{writeAddress[2]} " f"{virtFuncOverwrite_initSelf}\n")
        codeOutput.write(f"{writeAddress[3]} " f"{virtFuncOverwrite_solveAnimation}\n")
        assembleASMCode(regionLetter)
        with open(finalOut, 'r') as finalAssembly:
            for line in finalAssembly:
                codeOutput.write(line)
    with open(f"{region}.txt", 'a') as codeOutput:
        codeOutput.write(f"\n{codeDesc}")

def prepareAssembly():
    regionLetter = getRegion()
    region = processRegion(regionLetter)
    writeAddress = getWriteAddress(regionLetter)
    codeFile = Path(f"{region}.txt")
    if codeFile.is_file():
        os.remove(codeFile)
    assembleCode(region, regionLetter, writeAddress)
    os.remove(finalOut)

def main():
    pyiiasmh_path = Path(pyiiasmh)
    if pyiiasmh_path.is_file():
        print("System check passed.\n")
        prepareAssembly()
        print("\nOperation completed successfully.")
    else:
        print("PyiiASMH is required for this build script to function. Download PyiiASMH from 'https://github.com/JoshuaMKW/pyiiasmh' from the releases section and put it inside the tools directory.\n")
        sys.exit

main()
