# Update the number of controls.

# Inject @
# PAL   : 80855954
# NTSC-U: 80833ec4
# NTSC-J: 80854fc0
# NTSC-K: 80843d14

# .set region, '' # Fill with P, E, J, or K in the quotes to assemble for a particular region.
.if (region == 'P' || region == 'p')
    .set raceDataBase, 0x809c28d8 # Resolves to 809c7d28 (Racedata::spInstance)
.elseif (region == 'E' || region == 'e')
    .set raceDataBase, 0x809c7098
.elseif (region == 'J' || region == 'j')
    .set raceDataBase, 0x809c3878
.elseif (region == 'K' || region == 'k')
    .set raceDataBase, 0x809b4298
.else
    .err
.endif

# Add one additional control if the current game mode is NOT Time Trials.
addi r4, r4, 0x2                # Original instruction.
lis r11, raceDataBase@h
lwz r11, -raceDataBase@l (r11)
lwz r0, 0xB70 (r11)             # racedata -> racesScenario -> settings-> gameMode
cmpwi r0, 2
beq end
addi r4, r4, 0x1

end: