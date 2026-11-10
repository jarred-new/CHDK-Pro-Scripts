--[[
@title Quick Raw
@param n Noise Reduction
@default n 0
@range n 0 1
@param d Disable After Shoot
@default d 0
@range d 0 1
@param s Sound on Shoot
@default s 0
@range s 0 1
--]]

print("Preparing Raw...")
set_raw(1)
set_raw_nr(n)

if s == 1 then -- with sound
  play_sound(4)
  shoot()
else
  shoot() -- without sound
end

if d == 1 then -- disable if disable after shoot is activated
  set_raw(0)
  set_raw_nr(0)
end