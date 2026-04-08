# Prevent playback of the position change sound effects and the bounce animation (eOpen) if the Time Trial splits page is active.

# WRITE32 @
# PAL   : 048aa044 40440000
# NTSC-U: 048a471c 40440000
# NTSC-J: 048A91A4 40440000
# NTSC-K: 048984A4 40440000

# Inject @
# PAL   : 807f4b60
# NTSC-U: 807ea538
# NTSC-J: 807f41cc
# NTSC-K: 807e2f20

# .set region, '' # Fill with P, E, J, or K in the quotes to assemble for a particular region.
.if (region == 'P' || region == 'p')
    # Functions
    .set Animator_getGroup, 0x8063c820
    .set Group_setAnimation, 0x8063c91c
    # Data
    .set frameNumber, 0x808aa044
.elseif (region == 'E' || region == 'e')
    # Functions
    .set Animator_getGroup, 0x8060b400
    .set Group_setAnimation, 0x8060b4fc
    # Data
    .set frameNumber, 0x808a471c
.elseif (region == 'J' || region == 'j')
    # Functions
    .set Animator_getGroup, 0x8063be8c
    .set Group_setAnimation, 0x8063bf88
    # Data
    .set frameNumber, 0x808a91a4
.elseif (region == 'K' || region == 'k')
    # Functions
    .set Animator_getGroup, 0x8062ab38
    .set Group_setAnimation, 0x8062ac34
    # Data
    .set frameNumber, 0x808984a4
.else
    .err
.endif

lwz r11, 0x38 (r30)
cmpwi r11, 0
beq end                             # Anti-freeze
lwz r0, 0x8 (r11)                   # CtrlRaceRankNum->(TimeAttackSplitsPage&)->pageState
cmpwi r0, 1                         # Probably not needed. Will keep as a fail-safe.
beq freezeAnim
cmpwi r0, 3                         # Meat and mushrooms.
bne end
freezeAnim:
addi r3, r30, 0x98
li r4, 1                            # Set to animation group 1, "eRankTransition."
lis r12, Animator_getGroup@h
ori r12, r12, Animator_getGroup@l
mtctr r12
bctrl                               # Animator::getGroup
lis r5, frameNumber@h
li r4, 1                            # Set to animation group 1, "eRankTransition."
ori r5, r5, frameNumber@l
lfd f1, 0 (r5)                      # Freeze the animation in place. Explanation below.
/*

The game will call a function called "Group::setAnimation." In Pulsar based codebases, this function is called "AnimationGroup::PlayAnimationAtFrame." The way animation groups are set up, the programmer must define a frame range to call the animation. Unlike a DVD movie, the frame you choose won't jump to the middle of an animation as if you've seeked through and hit play, but instead will play whatever BRLAN file occurs at that frame from its very first frame to its last.

For example, in the animation group "eRankTransition" in "position.brctr," If you set the frame value (f1) to a float of 19.0f (0x4333000000000000), it will play the BRLAN animations from "eOpen" to "eWait". This is just the bounce with a light flash on the actual placement and then a freeze in place. If the frame value was set to 0.0f (0x0000000000000000), it will play the BRLAN animations from "eClose," then "eOpen," and then to "eWait." This is the animation that will cause the placement to shrink, grow back to full size, and then bounce with a light flash on the actual placement, then freeze.

Right before this hook, the function "Group::setAnimationAndDisable" ran, which, from a specified frame range, played the prior animation and then stopped it from looping. In this instance, the game is currently "paused" at frame 19. By running "Group::setAnimation" right after we can change the frame at which the animation is "paused."

The bug this code file is trying to fix is one where the bounce and light flash animation will play when we don't want it. By setting the first function argument (f1/float frame) to 40.0f (0x4044000000000000), we can force the game to play the BRLAN animation under "eWait" which is just the position tracker in its static position. Setting the wait animaion's start and end frames to positive values has shown no visual glitches or artifacts, making it compeletely safe.

*/
lis r12, Group_setAnimation@h
ori r12, r12, Group_setAnimation@l
mtctr r12
bctrl                               # Group::setAnimation
end:
mr r3, r30                          # Original instruction