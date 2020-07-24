breed [waves wave ]
breed [wavers waver ]
breed [buildings building ]
breed [seismographs seismograph ]

patches-own  [original-color ]

waves-own [ distance-traveled ]
buildings-own [strength-of-building startingstrength age seismic-retrofitting]
globals [
  map-edge-x    ;; horizontal distance from center to edge of map
  map-edge-y    ;; vertical distance from center to edge of map
  health-points ;; how many health points does the capital have
  stiffness  		;; how stiff the ground is to shaking
  friction			;; the friction in the movement of energy
  QUAKE-AMPLITUDE
  quake-frequency
]

wavers-own [
  edge?            ;; are we on the edge of the membrane?
  driver?          ;; are we part of the green driving plate?
  z                ;; position on z axis in space
  velocity         ;; velocity along z axis
  neighbor-turtles ;; agentset of turtles adjacent to us
  damage-potential
]

turtles-own [
  edge?            ;; are we on the edge of the map?
  driver?          ;; are we part of a fault line?
  z                ;; position on z axis in space
  velocity         ;; velocity along z axis
  neighbor-turtles ;; agentset of waver agents adjacent to us
]

to setup ; set upm the model
  clear-all
  setup-nettango
  set map-edge-x max-pxcor ;floor (max-pxcor / 8)
  set map-edge-y max-pycor ;floor (max-pycor / 8)
  set-default-shape turtles "circle"

  draw-simple-fault-lines

  ask patches [set original-color pcolor]
  setup-house 1 16

  ask patch -4 -7 [sprout-seismographs 1 [set shape "house" set size 5 set color yellow]]
  ask patches with [(abs pxcor <= map-edge-x) and
    (abs pycor <= map-edge-y)]
  [ sprout-wavers 1
    [ set edge? (abs xcor = map-edge-x) or
      (abs ycor = map-edge-y)
      if edge? [ set color 0 ]
      set driver? false
      if driver? [ set color green ]
      set z 0
      set velocity 0
      recolor ] ]
  ask wavers
    [ set neighbor-turtles wavers-on neighbors4 ]
  change-color-of-wavers
  ask buildings [set strength-of-building health-points-of-houses set startingstrength strength-of-building]
  reset-ticks
end

to recolor  ;; turtle procedure
  if not edge? and not driver?
    [ set color scale-color brown z -20 20 ]
     set damage-potential abs (color - 35)
end

to setup-house [x y]
  ask patch x y [if not any? other buildings in-radius 4 [sprout-buildings 1 [set shape "house" set size 5 set color blue set strength-of-building health-points-of-houses set startingstrength strength-of-building ]]]
end

to placehouse
  if mouse-down? [setup-house mouse-xcor mouse-ycor]

end

to go
  go-nettango
  ;ask wavers with [not driver? and not edge?]
   ; [ propagate ]
  ask wavers
    [ ifelse driver?
        [ set z (quake-amplitude * (sin (0.1 * quake-frequency * ticks))) ]
        [ set z (z + velocity)
          recolor ] ]
  change-color-of-wavers
  placehouse

  ask buildings
  [
    set label (word "health points: " precision strength-of-building 0)
    damage
    shake
  ]

  tick
end

to propagate   ;; turtle procedure -- propagates the wave from neighboring wavers
  set velocity (velocity +
                 (stiffness * 0.01 *
                   (sum [z] of neighbor-turtles
                    - 4 * z)))
  set velocity (((1000 - friction) / 1000) * velocity)
end


to change-color-of-wavers
   ask wavers
    [
      recolor
      show-turtle ]
end

to shake
  if strength-of-building < startingstrength - startingstrength / 5 [set shape "house1"]
  if strength-of-building < startingstrength - startingstrength / 2.5 [set shape "house2"]
  if strength-of-building < startingstrength - startingstrength / 1.667 [set shape "house3"]
  if strength-of-building < startingstrength - startingstrength / 1.25 [set shape "house4"]
  if strength-of-building <= 0 [set shape "house5" set strength-of-building 0 ]
end


to earthquake [col magnitute] ; starts a quake near fault lines which are color coded from the imported picture file
  ask n-of magnitute wavers with [pcolor = col]
  [ ; drivers are set to true if they are within a color range of col - 5 through col + 4
    set driver? [pcolor] of patch-here >= col - 5 and [pcolor] of patch-here <= col + 4
  ]
end

to stopearthquakes ; simply stops faults quaking
  ask wavers [ set driver? false]
end

to-report seismograph1 ; measures the absolute value of the seismic activity as tracked by color of wavers agents where the seismograph is located.
  let return 0
  let amp 0
  ask seismograph 1 [ ask one-of wavers-here [ set amp color] ]
  set return amp - 35

  report return
end


to damage ; measures to amount of ground shift of the capital building and decrements the structural integrity of the building accordingly
  let amp 0

  ask wavers-here [ set amp color]
  set strength-of-building strength-of-building - abs (amp - 35)



end

to draw-simple-fault-lines
  ;set orange Wassacht fault
  ask patches with [ pxcor = 8 and pycor < 0 and pycor > -15] [set pcolor orange]
  ask patch 7 -15 [set pcolor orange] ; orange is color 25
  ask patch 6 -16 [set pcolor orange]
  ask patch 5 -15 [set pcolor orange]

  ;set up red Granger Fault
  ask patch -8 3 [set pcolor red] ; red is color 15
  ask patch -9 4 [set pcolor red] ; red is color 15
  ask patch -10 5 [set pcolor red] ; red is color 15
  ask patch -11 6 [set pcolor red] ; red is color 15

  ;set magenta Taylorsville fault
  ask patches with [ pxcor = -6 and pycor < 4 and pycor > 0] [set pcolor magenta] ; magenta is color 125

  ;set cyan Beach fault
  ask patches with [ pxcor = 4 and pycor < 4 and pycor > 0] [set pcolor cyan] ; cyan is color 65

  ;set cyan Beach fault
  ask patches with [ pycor = 16 and pxcor < 6 and pxcor > 1] [set pcolor lime] ; green is color 65

  ;set yellow West Valley fault
  ask patches with [ pxcor = -6 and pycor < 13 and pycor > 8] [set pcolor yellow] ; magenta is color 125
end

; Code for Earthquake model
to quake
  Earthquake 15 (1)
end



; Copyright 2020 Kit Martin.
@#$#@#$#@
GRAPHICS-WINDOW
248
14
628
539
-1
-1
12.0
1
10
1
1
1
0
0
0
1
-15
15
-21
21
1
1
1
days
30.0

BUTTON
35
45
113
78
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
115
45
192
78
go/pause
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

BUTTON
40
165
170
199
stop all earthquakes
stopearthquakes
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
630
20
880
185
Damage Potential of Earthquake
NIL
NIL
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 1 -16777216 true "" "histogram [damage-potential] of wavers "

PLOT
630
195
880
397
Yellow seismograph
Time
Strength
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -13290229 true "" "plot seismograph1"

BUTTON
10
245
196
339
Clean up Destroyed Buildings
Ask buildings with [color = blue and strength-of-building < 1] [ die]
NIL
1
T
OBSERVER
NIL
C
NIL
NIL
1

BUTTON
45
105
171
149
start an earthquake
quake
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
15
350
195
410
Please, click on the screen to add buildings.
16
0.0
0

SLIDER
10
420
221
453
health-points-of-houses
health-points-of-houses
0
1000
347.0
1
1
NIL
HORIZONTAL

PLOT
638
408
880
558
Health of Houses
NIL
NIL
0.0
500.0
0.0
10.0
true
false
"" ""
PENS
"default" 4.0 1 -16777216 true "" "Histogram [strength-of-building] of buildings"

@#$#@#$#@
## WHAT IS IT?
Even though earthquakes can’t be predicted we do have an idea of where they occur and how to measure them using a seismograph. Students investigate a phenomenon that exemplifies the pattern. In the model the blue capital building collapses when it's structural integrity reaches zero due to earthquakes.


## HOW IT WORKS
A wave of enegery starts aat one of the six fault lines on the map. The waver agents pass that energy to each other. This creates a wave that progagates outwards. When the wave hits the blue capital building it damges the building. When the wave hits the yellow seismograph building it moves the seismograph inside.


## HOW TO USE IT
Press "setup" and then "go". Then press one of the earthquake buttons such as "West Valley Fault Quake". To stop the quake press "Stop all Earthquakes" 


## THINGS TO TRY
Try changing stiffness, friction, quake amplitute, or quake frequency.

## EXTENDING THE MODEL



## NETLOGO FEATURES


## CREDITS AND REFERENCES

This model builds of the Wave Machine Model (Wilensky, 1997).



## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Kit Martin. (2020).  NetLogo Salt Lake Earthquake model.  

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE



![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: Theory Building:   The project gratefully acknowledges the support of the National Science Foundation 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

house1
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120
Line -16777216 false 45 255 75 225
Line -16777216 false 75 225 75 180
Line -16777216 false 75 180 60 165
Line -16777216 false 75 180 105 165
Line -16777216 false 105 165 105 135
Line -16777216 false 105 165 135 150
Line -16777216 false 255 225 240 225
Line -16777216 false 240 225 210 195
Line -16777216 false 240 225 210 240
Line -16777216 false 210 240 210 255

house2
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120
Line -16777216 false 45 255 75 225
Line -16777216 false 75 225 75 180
Line -16777216 false 75 180 60 165
Line -16777216 false 75 180 105 165
Line -16777216 false 105 165 105 135
Line -16777216 false 105 165 135 150
Line -16777216 false 255 225 240 225
Line -16777216 false 240 225 210 195
Line -16777216 false 240 225 210 240
Line -16777216 false 210 240 210 255
Line -16777216 false 255 150 210 165
Line -16777216 false 210 165 195 150
Line -16777216 false 135 150 150 165
Line -16777216 false 135 150 150 135
Line -16777216 false 150 135 165 135
Line -16777216 false 195 150 180 165
Line -16777216 false 195 150 195 135
Line -16777216 false 210 195 195 195
Line -16777216 false 210 195 210 180
Line -16777216 false 210 240 195 225
Line -16777216 false 195 225 195 240
Line -16777216 false 75 225 105 240
Line -16777216 false 105 240 105 270
Line -16777216 false 75 285 75 255
Line -16777216 false 75 255 90 240
Line -16777216 false 90 240 90 195
Line -16777216 false 60 165 60 150
Line -16777216 false 105 135 75 120
Line -16777216 false 180 165 150 195
Line -16777216 false 150 195 135 195
Line -16777216 false 150 195 165 210

house3
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 195 285 195 180 300 285
Line -16777216 false 30 120 270 120
Line -16777216 false 45 255 75 225
Line -16777216 false 75 225 75 180
Line -16777216 false 75 180 60 165
Line -16777216 false 75 180 105 165
Line -16777216 false 105 165 105 135
Line -16777216 false 105 165 135 150
Line -16777216 false 255 225 240 225
Line -16777216 false 240 225 210 195
Line -16777216 false 240 225 210 240
Line -16777216 false 210 240 210 255
Line -16777216 false 255 150 210 165
Line -16777216 false 210 165 195 150
Line -16777216 false 135 150 150 165
Line -16777216 false 135 150 150 135
Line -16777216 false 150 135 165 135
Line -16777216 false 195 150 180 165
Line -16777216 false 195 150 195 135
Line -16777216 false 210 195 195 195
Line -16777216 false 210 195 210 180
Line -16777216 false 210 240 195 225
Line -16777216 false 195 225 195 240
Line -16777216 false 75 225 105 240
Line -16777216 false 105 240 105 270
Line -16777216 false 75 285 75 255
Line -16777216 false 75 255 90 240
Line -16777216 false 90 240 90 195
Line -16777216 false 60 165 60 150
Line -16777216 false 105 135 75 120
Line -16777216 false 180 165 150 195
Line -16777216 false 150 195 135 195
Line -16777216 false 150 195 165 210

house4
false
0
Rectangle -7500403 true true 105 195 195 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 195 285 195 180 300 285
Line -16777216 false 255 225 240 225
Line -16777216 false 240 225 210 195

house5
false
0
Rectangle -7500403 true true 105 270 195 285
Rectangle -16777216 true false 120 255 180 285
Polygon -7500403 true true 195 285 225 255 300 285
Line -16777216 false 255 225 240 225
Line -16777216 false 240 225 210 195
Rectangle -7500403 true true 0 270 90 285
Polygon -7500403 true true 0 285 30 255 105 285

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
