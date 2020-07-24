extensions [import-a fetch]

breed [waves wave ]
breed [wavers waver ]
breed [buildings building ]
breed [seismographs seismograph ]

patches-own  [original-color ]

waves-own [ distance-traveled ]
globals [
  map-edge-x    ;; horizontal distance from center to edge of map
  map-edge-y    ;; vertical distance from center to edge of map
  health-points ;; how many health points does the capital have
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
  x                ;; position on x axis in space
  y                ;; position on y axis in space
  z                ;; position on z axis in space
  velocity         ;; velocity along z axis
  neighbor-turtles ;; agentset of waver agents adjacent to us
]

to setup
  clear-all
  set map-edge-x max-pxcor ;floor (max-pxcor / 8)
  set map-edge-y max-pycor ;floor (max-pycor / 8)
  set-default-shape turtles "circle"
  import-pcolors "earthquakemapcoloredfaults.png"
  ;ask patches with [pcolor >= 10 and pcolor <= 19] [ set pcolor 15 ]
  draw-in-fault-lines

  ;ask patches with [pcolor >= 120 and pcolor < 130] [ set pcolor 125 ]
  ;ask patches with [pcolor >= 40 and pcolor < 50] [ set pcolor 45 ]
  ;ask patches with [pcolor >= 20 and pcolor < 30] [ set pcolor 25 ]
  ;ask patches with [pcolor >= 80 and pcolor < 90] [ set pcolor 85 ]
  ;ask patches with [pcolor >= 60 and pcolor < 70] [ set pcolor 65 ]
  ask patches [set original-color pcolor]
  ask patch 1 16 [sprout-buildings 1 [set shape "house" set size 5 set color blue]]
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
  set health-points Damage-threshold-of-capital
  reset-ticks
end

to recolor  ;; turtle procedure
  if not edge? and not driver?
    [ set color scale-color brown z -20 20 ]
     set damage-potential abs (color - 35)
end

to go
  ask wavers with [not driver? and not edge?]
    [ propagate ]
  ask wavers
    [ ifelse driver?
        [ set z (quake-amplitude * (sin (0.1 * quake-frequency * ticks))) ]
        [ set z (z + velocity)
          recolor ] ]
  change-color-of-wavers
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


to earthquake [col] ; starts a quake near fault lines which are color coded from the imported picture file
  ask wavers
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


to-report damage ; measures to amount of ground shift of the capital building and decrements the structural integrity of the building accordingly
  let return 0
  let amp 0

  ask building 0 [ ask one-of wavers-here [ set amp color] ]
  set health-points health-points - abs (amp - 35)
  if health-points < 0 [ask building 0 [ht] set health-points 0 ]

  report health-points
end

to draw-in-fault-lines
   ask patches with [pxcor = one-of [
1
4
1
4
3
4
4
3
4
3
3
3
4
4
3
1
4
3
1
4
4
1
4
3
3
1
-21
3
1
4
3
3
3
3
3
4
1
3
4
1
1
4
4
1
3
4
3
3
1
1
3
1
1
1
4
4
-24
4
3
1
1
4
4
1
1
1
4
1
3
4
3
4
3
3
4
3
3
4
1
1
4
3
1
1
3
4
4
4
    1]  and pycor = one-of [ 31
-2
9
22
37
4
10
-21
-7
-9
-21
12
-18
17
41
-22
35
33
-10
-33
-15
19
-14
1
-40
34
-24
-40
-16
31
-12
32
18
-8
-5
-15
33
-36
-43
31
17
-32
25
-22
27
19
32
-17
-19
-19
0
23
-12
-29
-5
-33
-24
28
-25
4
-34
-24
3
3
17
-38
-41
40
25
-31
41
-39
20
14
8
16
-14
29
-27
8
29
-5
-42
-34
9
36
    -37]]

  [set pcolor 15  ]

 ask patches with [pxcor = one-of [
    -14
-14
-13
-12
-13
-13
-14
-14
-11
-13
-15
-10
    -13] and pycor = one-of [23
27
24
25
28
24
20
28
29
18
23
33
    27]] [set pcolor 45]
;assigning the green patches for the virginia street fault
  ask patches with [pxcor = one-of [
1
3
5
2
    -13] and pycor = one-of [
31
32
32
32]] [set pcolor 65]
  ;assigning the magenta patches for the Taylorsville fault
  ask patches with [pxcor = one-of [
-11
-14
-11
-15
-15
-13
-12
-15] and pycor = one-of [
6
4
5
17
12
15
16
10]] [set pcolor 125]
    ;assigning the teal patches for the Beach fault
  ask patches with [pxcor = one-of [
9
7
5
7] and pycor = one-of [
4
10
4
7]] [set pcolor 85]
      ;assigning the orange patches for the Wassacht fault
  ask patches with [pxcor = one-of [
11
14
14
16
8
14
17
13
10
13
15
9
16
15
16
17
17
16
15
13
15
16
8
16
9
8
15
16
12
16
13
11
14
16
16
16
14
12
15
13
17
17
9
8
15
16
14
15
15
8
15
15
10
16
15
12
17
16
17
16
14
14] and pycor = one-of [
-33
-23
-32
-35
-8
-1
-29
-32
-21
-31
-8
-19
-20
-31
-4
-3
-16
-35
-34
-17
-7
-20
-6
-27
-39
1
-6
0
0
-28
-24
-34
-12
-23
-10
-15
-9
-9
-37
-28
-29
-41
-14
-27
-26
-25
-18
-4
-19
-30
-30
-33
-17
-5
-24
-36
-3
-11
-26
-1
0
-40]] [set pcolor 85]
end

to test-fetch-file-sync
  clear-all
  show (fetch:file user-file)
end

to test-fetch-file-async
  clear-all
  fetch:file-async user-file show
end

to test-fetch-url-sync
  clear-all
  show (fetch:url (word "file://" user-file))
end
; Copyright 2020 Kit Martin.
@#$#@#$#@
GRAPHICS-WINDOW
248
14
622
545
-1
-1
6.0
1
10
1
1
1
0
0
0
1
-30
30
-43
43
1
1
1
ticks
30.0

BUTTON
15
42
93
75
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
97
42
174
75
NIL
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

SLIDER
10
114
150
147
stiffness
stiffness
0
50
43.0
1
1
NIL
HORIZONTAL

SLIDER
10
235
150
268
quake-amplitude
quake-amplitude
0
30
14.0
1
1
NIL
HORIZONTAL

SLIDER
10
275
150
308
quake-frequency
quake-frequency
0
100
80.0
1
1
NIL
HORIZONTAL

SLIDER
10
150
151
183
friction
friction
0
99
21.0
1
1
NIL
HORIZONTAL

TEXTBOX
14
92
135
112
Ground Settings
11
0.0
0

TEXTBOX
8
211
138
229
Fault line settings
11
0.0
0

BUTTON
763
25
925
58
Granger Fault Quake 
Earthquake 15
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
934
25
1093
58
Stop all Earthquakes
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

BUTTON
757
60
929
93
West Valley Fault Quake
earthquake 45
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
757
95
934
128
Taylorsville Fault Quake
earthquake 125
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
747
130
939
163
Virginia Street Fault Quake
earthquake 65
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
772
165
914
198
Beach Fault Quake
earthquake 85
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
762
200
919
233
Wasatch Fault Quake
earthquake 25
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
747
250
997
415
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
747
425
997
627
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

SLIDER
10
360
205
393
Damage-threshold-of-capital
Damage-threshold-of-capital
0
50
49.0
1
1
NIL
HORIZONTAL

MONITOR
10
400
202
445
Structural Integrity of Capital
damage
2
1
11

TEXTBOX
20
325
185
351
Blue Capital Building Settings
11
0.0
1

TEXTBOX
254
567
442
731
add houses with mouse click\nmodule capital\nmove seismograph\n\nLevel 2\nfeatures of home: age, retrofitted, \nchange ground properties, igneous (more pours medium), metamorphic (hard), and sedamentry (really going to move) rock
11
0.0
1

TEXTBOX
72
192
260
215
None of these are 7th grade
11
0.0
1

TEXTBOX
1032
307
1220
852
Blocks\nagents buildings, faultlines, ground particles\n\nagent behavior\nask fault line\n[\nmove (stronger or weaker (magnitude)]\n]\n\nask building\n[\nshake (visualization for houses)\nset draw crack (5)\nset draw more cracks (6)\nset roof break of roof (7)\nset just the door (8)\nset destroy building threshold (9)\n\nuse mouse to place houses\ngenerate scenarios of where houses are \nso can compare\n\n\n]\n\nask particles\n[\nmove if neighbor is moving\n]\n\n\n\ninteractions\n\nvariables\n\n
11
0.0
1

TEXTBOX
732
668
920
758
measure distance from epicent and house\nhave one spot on the fault move. Measure distance from that spot
11
0.0
1

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
1
@#$#@#$#@
