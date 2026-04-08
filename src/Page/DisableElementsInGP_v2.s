# Disable elements of the page if in Grand Prix and prevent saving ghost data.

# Inject @
# PAL   : 80855c24
# NTSC-U: 80834194
# NTSC-J: 80855290
# NTSC-K: 80843fe4

# .set region, '' # Fill with P, E, J, or K in the quotes to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Racedata
    .set raceDataBase, 0x809c28d8 # Resolves to 809bd728 (Racedata::spInstance)
    # Functions
    .set LayoutUIControl_clearMessage, 0x8063deec
    # Data
    .set ghostMessage_paneName, 0x808b5869
    # Return Addresses
    .set return, 0x80856158
.elseif (region == 'E' || region == 'e')
    # Racedata
    .set raceDataBase, 0x809c7098
    # Functions
    .set LayoutUIControl_clearMessage, 0x8060cacc
    # Data
    .set ghostMessage_paneName, 0x808b5cf1
    # Return Addresses
    .set return, 0x808346c8
.elseif (region == 'J' || region == 'j')
    # Racedata
    .set raceDataBase, 0x809c3878
    # Functions
    .set LayoutUIControl_clearMessage, 0x8063d558
    # Data
    .set ghostMessage_paneName, 0x808b6709
    # Return Addresses
    .set return, 0x808557c4
.elseif (region == 'K' || region == 'k')
    # Racedata
    .set raceDataBase, 0x809b4298
    # Functions
    .set LayoutUIControl_clearMessage, 0x8062c204
    # Data
    .set ghostMessage_paneName, 0x808a7409
    # Return Addresses
    .set return, 0x80844518
.else
    .err
.endif

lis r11, raceDataBase@h
lwz r11, -raceDataBase@l (r11)
lwz r0, 0xb70 (r11)                                         # racedata->racesscenario->settings->gamemode
cmpwi r0, 2                                                 # Execute the rest of the host function if in Time Trials. (racedata->racesscenario->settings->gamemode)
beq end

# Clear the ghost save message.
lis r12, LayoutUIControl_clearMessage@h
addi r3, r29, 0x370
ori r12, r12, LayoutUIControl_clearMessage@l                # LayoutUIControl::clearMessage
lis r4, ghostMessage_paneName@h
mtctr r12
subi r4, r4, ghostMessage_paneName@l                        # "Textbox_00" Used by both ghost data status and the "LIVE" text in online spectating.
bctrl

# Exit hook, and by extension, the host function.
lis r11, return@h
ori r11, r11, return@l
mtctr r11
bctr
end:
lis r3, 0x809c                                              # Original instruction.
