;extensions [profiler]


globals [
  membrane-edge-x  ;; horizontal distance from center to edge of membrane
  membrane-edge-y  ;; vertical distance from center to edge of membrane
  membrane-center
  detector-value-1
  detector-value-2
  membrane-surface
  atom-batch-twist
 ; driver-vibration-frequency
  red-detector-size
  blue-detector-size
  length-of-simulation
 ; stength-of-push
  empty-space
  #atoms
  vibrate-particles?
  dark-friction-in-medium
  stiffness
  distance-of-blue-squares-from-sound-source
  particle-shape
  friction-in-medium
  particle-size
  slide-step
  vibration-amplitude
  vibration-frequency
  speaker-on?
  speaker-visible?
  particles?
  hearer?
]


breed [grids grid]
breed [arrows arrow]
breed [dark-particles dark-particle]
breed [boundaries boundary]
breed [atoms atom ]
breed [detectors detector]
breed [graphics-detectors graphic-detector]

arrows-own [
  edge?            ;; are we on the edge of the membrane?
  driver?          ;; are we part of the green driving plate?
  x                ;; position on x axis in space
  y                ;; position on y axis in space
  z                ;; position on z axis in space
  velocity         ;; velocity along z axis
  neighbor-particles ;; agentset of particles adjacent to us
]

dark-particles-own [
  edge?
  driver?
  x                ;; position on x axis in space
  y                ;; position on y axis in space
  z                ;; position on z axis in space
  velocity         ;; velocity along z axis
  neighbor-particles ;; agentset of particles adjacent to us
]

boundaries-own [
  edge?
  driver?
  x                ;; position on x axis in space
  y                ;; position on y axis in space
  z                ;; position on z axis in space
  velocity         ;; velocity along z axis
  neighbor-particles ;; agentset of particles adjacent to us
]


patches-own [detector? detector-number]

atoms-own [kind x y offset-distance tracking?]



to setup-nl
  clear-all
  set particle-size 1.0
  ; set stiffness 3.0
  set vibrate-particles? true
  set empty-space 1
  set #atoms 3
  set slide-step 20
  set friction-in-medium 0
  set distance-of-blue-squares-from-sound-source 1
  set dark-friction-in-medium 6
  set length-of-simulation 499
  set red-detector-size 1
  set blue-detector-size 1
  set atom-batch-twist false
  set membrane-surface ""
  set membrane-surface "rigid"
  set particle-shape "offset-circle"
  set speaker-on? false
  set speaker-visible? false
  set particles? false
  set hearer? false
  
  setup

  
create-graphics-detectors 1 [set color black setxy -3.5 0 set size 6 set shape "detector" set hidden? true]

  ask patches [set detector? false set pcolor white]
  ask patches with [(pxcor <= max-pxcor  - 1) and pycor = 0]
    [ sprout 1
        [ set breed arrows
         ; set color [0 255 0 150]
           set hidden? true
           set edge? false
           set driver? false
           set size 1.1
          if (( pxcor >= (min-pxcor + 2) and pxcor <= min-pxcor + 3) and pxcor != max-pxcor and speaker-visible?)
             [set shape "rectangle" set color orange set hidden? false set size 3.6
               if (speaker-on?) [set driver? true]
           ]
          set x xcor
          set y ycor
          set z 0
          set velocity 0
          ]
        ]
  
  if (hearer?)
  [ask patch 17 0
  	[sprout 1
  	  [ set shape "person-with-ears" set size 4 set color gray]
  	]
  ]

  if (particles?)
  [ask patches with [(pxcor <= max-pxcor  - 1) and pycor = 0][
     sprout 1
     [
       set breed dark-particles
       set edge? false
       set driver? false

       set x xcor
       set y ycor
       set z 0

       set velocity 0
       set hidden? true
      ; repack-new
     ]
   ]
  ]

   ask patches with [(pxcor = max-pxcor) and pycor >= (min-pycor + empty-space) and pycor <= (max-pycor - empty-space)][
     sprout 1
     [
       set breed boundaries
       set edge? false
       set driver? false
       set color violet
       set x xcor
       set y ycor
       set z 0
       set velocity 0
       set hidden? true
     ;  repack-new
     ]
   ]

  ask arrows
    [
      let these-particle-neighbors arrows-on neighbors4
      let these-boundary-neighbors boundaries-on neighbors4
      let myxcor x
    ;  if (driver?) [set hidden? false]
    ;  set shape "square"
    ;  set size 2

    ifelse myxcor = (max-pxcor - 1) [set neighbor-particles (turtle-set these-particle-neighbors these-boundary-neighbors) with [x != myxcor] ]
      [  set neighbor-particles these-particle-neighbors with [x != myxcor] ]
     ]

    ask dark-particles
    [
      let these-dark-neighbors dark-particles-on neighbors4
      let these-boundary-neighbors boundaries-on neighbors4
      let myxcor x
      ifelse myxcor = (max-pxcor - 1) [ set neighbor-particles (turtle-set these-dark-neighbors these-boundary-neighbors) with [x != myxcor]]
      [ set neighbor-particles these-dark-neighbors with [x != myxcor]  ]
   ]

   ask boundaries
    [
      let these-dark-neighbors dark-particles-on neighbors4
      let these-particle-neighbors arrows-on neighbors4
      let myxcor x
      set neighbor-particles (turtle-set these-dark-neighbors these-particle-neighbors) with [x != myxcor]
     ]

    ask patches [
     let min-xpos -5

      if (pxcor >= (min-xpos + distance-of-blue-squares-from-sound-source) and pxcor <= (min-xpos + distance-of-blue-squares-from-sound-source + 1)  ) and (abs pycor < 2 )
      [set detector? true]


    ]

  ;  ask patches [
  ;  sprout 1 [set breed grids set shape "grid" set color [255 255 255 55] stamp die]
  ;  ]
  if (particles?) [make-atoms-new]
   ;   ask atoms [
     ;  ifelse show-particles-in-medium?
   ;    [set hidden? not show-particles-in-medium?]
  ;     [set hidden? not show-particles-in-medium?]
  ;    ]
  repack-new
 ; calculate-detector-values
;

  reset-ticks
end








to make-atoms-new
   let counter-x 0
   let min-x (min-pxcor + 5)
   let x-offset -.45
   let x-offset-2 0
   let x-offset-3 0
   let counter-y 0
   let min-y -1.4
   let closest-particle nobody

   repeat 3 [
   repeat 2 [

   repeat 2 [

     repeat (abs (min-x * 2) + 4) [
       create-atoms 1 [set breed atoms set size (.45 * particle-size) set color [50 175 50] set shape "offset-circle" set hidden? false
            setxy (min-x + counter-x + x-offset + x-offset-2 + x-offset-3 ) (min-y + counter-y)
            set offset-distance (pxcor - xcor)
            rt random 360
            set color [50 175 50]
            set closest-particle min-one-of arrows [distance myself]
            create-link-from closest-particle [tie set hidden? true]
            set x xcor
            set y ycor
            set tracking? false
       ]
       set counter-x counter-x + 1

     ]
     set counter-x 0
     set x-offset x-offset + 0.5
     set counter-y counter-y + 0.25
   ]
     set x-offset -.45
     set x-offset-2 x-offset-2 + (0.052)
   ]

     set x-offset -.45
    ; set x-offset-2  0
     set x-offset-3 x-offset-3 - (0.16)

   ]



ask arrows with [not edge? and not driver?] [set hidden? true]
end

to repack  ;; turtle procedure'
  let my-xcor 0
 ask (turtle-set arrows boundaries dark-particles) [
  if not edge?
    [
      setxy x y
      set heading -90

      fd z / slide-step

      ]
   ]
end

to repack-new  ;; turtle procedure'
  let my-xcor 0

  ask (turtle-set arrows boundaries dark-particles) [
  if not edge?
    [
      setxy x y
      set heading -90
      fd z / slide-step
      ]
   ]

 ask (arrows) [
  if not edge?
    [

      let this-z z
    ;  fd z / slide-step
      if breed = arrows and any? link-neighbors [
        set my-xcor x
        let left-neighbor-particle  one-of neighbor-particles with [x < my-xcor]
        let right-neighbor-particle one-of neighbor-particles with [x > my-xcor]
        let z-left [z] of left-neighbor-particle
        let z-right[z] of right-neighbor-particle

        ask link-neighbors [
          set xcor x
          set ycor y
          set heading -90
          fd this-z / slide-step
          if offset-distance < 0 [fd offset-distance *  (z-left  - this-z) / slide-step]
          if offset-distance > 0 [fd offset-distance *  (this-z - z-right) / slide-step]
        ;  if wiggle? [rt random 360]
        ]

       ]  ;ask atoms with []
      ]
   ]

end


to check-driver

    ask arrows

    [
       let driver-vibration-frequency vibration-frequency * 30
      ifelse driver?
      [ set z (vibration-amplitude * -1 * (sin (0.1 * driver-vibration-frequency * ticks))) ]
          ; if (0.1 * driver-vibration-frequency * ticks) / 360 >= #-of-repeated-vibrations [set z 0] ]
        [ set z (z + velocity)]
     ; set hidden? true
     ]
  ask boundaries      [ set z (z + velocity)]
  ask dark-particles  [ set z (z + velocity)]
end

to propagate-across-particles-nt
  ask arrows with [not edge?]
  [ propagate-across-particles friction-in-medium ]
  ask boundaries
    [ propagate-across-particles friction-in-medium]
  ask dark-particles
    [ propagate-across-particles dark-friction-in-medium]
end

to propagate-across-particles-turtles
  if (breed = arrows and not edge?)
  [ propagate-across-particles friction-in-medium]
  if (breed = boundaries)
  [ propagate-across-particles friction-in-medium]
  if (breed = dark-particles)
  [ propagate-across-particles dark-friction-in-medium]
  
end
  

to go-nl
  ;if (ticks >  length-of-simulation) [stop]
  
  ;propagate-across-particles-nt


  check-driver

  check-mouse-click

  repack-new
  ;calculate-detector-values

  tick
  go
end



to check-mouse-click
  if mouse-down? and mouse-inside? [
    let this-mouse-xcor mouse-xcor
    let this-mouse-ycor mouse-ycor

    let atoms-near-mouse atoms with [sqrt (((xcor - mouse-xcor) ^ 2) + ((ycor - mouse-ycor) ^ 2)) <= .25  ]
    ask atoms [set tracking? false set color [50 175 50]]
    if any? atoms-near-mouse [ask atoms-near-mouse [set tracking? true]]
  ]


    if mouse-inside?
      [ask atoms with [tracking? = true][set color red] ]

end

to propagate-across-particles [this-friction-in-medium]  ;; turtle procedure -- propagates the wave from neighboring particles

  set velocity (velocity +  (stiffness * 0.01) *  (sum [z] of neighbor-particles -  2 * z))
  set velocity (((1000 - this-friction-in-medium) / 1000) * velocity)
end


to-report #-atoms-at-detector
  let p 0
  ifelse show-detector-region?
  [ask patches with [pxcor >= -4 and pxcor <= -3] [set pcolor red + 4]
     set p (count atoms with [pxcor >= -4 and pxcor <= -3] )]
      [set p 0 ask patches with [pxcor >= -4 and pxcor <= -3] [set pcolor 9.9]]
  report p
end

to-report #-atoms-at-ear
  let p (count atoms with [pxcor >= 15 and pxcor <= 16])
  report p
end




; Copyright 1997 Uri Wilensky.
; See Info tab for full copyright and license.
; --- NETTANGO BEGIN ---

; This block of code was added by the NetTango builder.  If you modify this code
; and re-import it into the NetTango builder you may lose your changes or need
; to resolve some errors manually.

; If you do not plan to re-import the model into the NetTango builder then you
; can safely edit this code however you want, just like a normal NetLogo model.

; Code for Sound Waves Through A Medium
to go
  ask turtles
  [
    propagate-across-particles-turtles
  ]
end

to setup
  set vibration-amplitude (21)
  set vibration-frequency (2)
  set stiffness ("10")
  set friction-in-medium ("0")
  set speaker-visible? true
  set speaker-on? true
  set particles? true
  set hearer? true
end
; --- NETTANGO END ---
@#$#@#$#@
GRAPHICS-WINDOW
28
69
916
189
-1
-1
24
1
10
1
1
1
0
0
1
1
-18
18
-2
2
1
1
1
ticks
30

BUTTON
20
16
109
49
setup
setup-nl
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
112
16
204
49
go/pause
go-nl
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
207
16
262
49
>
go-nl
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

TEXTBOX
22
208
206
226
Orange sound source
14
0
1

SWITCH
260
230
461
263
show-detector-region?
show-detector-region?
0
1
-1000

PLOT
262
266
526
466
molecules in red detector region
NIL
NIL
0
10
0
10
true
false
"" ""
PENS
"default" 1 0 -16777216 true "" "plot #-atoms-at-detector"

PLOT
649
270
915
465
energy reaching hearer
NIL
NIL
0
10
0
10
true
false
"" ""
PENS
"default" 1 0 -16777216 true "" "plot #-atoms-at-ear"
@#$#@#$#@
## WHAT IS IT?
A speaker plays sound at different volumes. The greater the movement of the speaker the louder the sound and the greater the amplitude of the particle movement. 

## HOW IT WORKS
A speaker, air particles, an ear, electricity (energy)  going to the speaker

Like a cross between these
https://phet.colorado.edu/en/simulation/sound (First two tabs)

https://javalab.org/en/tuning_fork_and_sound_wave_en/ (moving particles)

https://www.acs.psu.edu/drussell/Demos/waves/wavemotion.html (the top two models show the amplitude and frequency as bands. The red dot shows the particle and the arrow shows the wave))

https://www.physicsclassroom.com/Physics-Interactives/Waves-and-Sound/Simple-Wave-Simulator/Simple-Wave-Simulator-Interactive
(click “show waves as sound”)

Here is the same model as a standing wave.  It is better than the one above.
https://www.physicsclassroom.com/Physics-Interactives/Waves-and-Sound/Standing-Wave-Patterns/Standing-Wave-Patterns-Interactive
(click “show wave as sound)


## HOW TO USE IT

## THINGS TO TRY

## EXTENDING THE MODEL

## NETLOGO FEATURES

## CREDITS AND REFERENCES

Developed by Michael Novak, Northwestern University, Evanston, IL.

Modified by Kit Martin, Northwestern University, Evanston, IL.

Modified by Maryam Hedayati, Northwestern University, Evanston, IL.

This model is based on the code from the NetLogo Wave Machine model:  http://ccl.northwestern.edu/netlogo/models/WaveMachine.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.


## HOW TO CITE

If you mention this model in a publication, we ask that you include these citations:

*Michael Novak (2014). Sound Waves through a Medium. https://www.nextgenstorylines.org/how-can-sense-so-many-different-sounds. Next Generation Science Story Lines.

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.


## COPYRIGHT AND LICENSE

Copyright 1997 Uri Wilensky.

![CC BY-NC-SA 3.0](http://i.creativecommons.org/l/by-nc-sa/3.0/88x31.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

This model was created as part of the project: CONNECTED MATHEMATICS: MAKING SENSE OF COMPLEX PHENOMENA THROUGH BUILDING OBJECT-BASED PARALLEL MODELS (OBPML).  The project gratefully acknowledges the support of the National Science Foundation (Applications of Advanced Technologies Program) -- grant numbers RED #9552950 and REC #9632612.

This model was converted to NetLogo as part of the projects: PARTICIPATORY SIMULATIONS: NETWORK-BASED DESIGN FOR SYSTEMS LEARNING IN CLASSROOMS and/or INTEGRATED SIMULATION AND MODELING ENVIRONMENT. The project gratefully acknowledges the support of the National Science Foundation (REPP & ROLE programs) -- grant numbers REC #9814682 and REC-0126227. Converted from StarLogoT to NetLogo, 2001.
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

detector
false
0
Rectangle -7500403 false true 101 75 200 227

dot
false
0
Circle -7500403 true true 90 90 120

driver
false
0
Rectangle -7500403 true true 135 30 195 270

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

filled circle
true
0
Circle -7500403 true true 27 27 216

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

grid
false
0
Rectangle -7500403 false true 0 0 300 300

half-face
false
0
Rectangle -7500403 true true -150 -15 150 300

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

nothing
true
0

offset-circle
true
0
Circle -7500403 true true 16 16 268

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

person-with-ears
false
0
Circle -7500403 true true 60 60 180
Rectangle -7500403 true true 105 225 195 270
Polygon -7500403 true true 225 120 255 105 255 195 225 180
Polygon -7500403 true true 75 120 45 105 45 195 75 180
Circle -1 true false 150 90 60
Circle -1 true false 90 90 60
Circle -1 true false 105 120 0
Circle -16777216 true false 144 99 42
Circle -16777216 true false 84 99 42
Polygon -1 true false 105 180 135 210 180 210 210 180 165 195 150 195 105 180

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

rectangle
false
0
Rectangle -955883 true false 90 0 210 300

solid circle
true
0
Circle -7500403 true true 2 2 297

square
false
0
Rectangle -7500403 true true 0 -15 300 300

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
NetLogo 6.1.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0
-0.2 0 0 1
0 1 1 0
0.2 0 0 1
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@

@#$#@#$#@
