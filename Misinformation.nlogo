breed [sources source]
breed [people person]
undirected-link-breed [ss-ps s-p] ;; connection between sourceS-peopleS / source-person
undirected-link-breed [ps-ps p-p] ;; connection between peopleS-peopleS / person-person

turtles-own
[
  belief              ;; the person's strength of belief in the thoery
  influenceable       ;; the influenceable of a person, so how well that person can persuade other individuals
  misinformed?        ;; if true, the peron beliefs in tick the beginning (tick one)
  news-trust?         ;; if true, trusts the news media
]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; SETUP ;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  setup-sceen-size
  ;;ask patches [ set pcolor white ]
  setup-people
  setup-friends-network
  setup-news
  ask n-of ((percent-misinformed * number-of-people) / 100) people [
    set misinformed? true
    set shape "sheep 2"
    set color red
    set belief 100
  ]
  ask ps-ps [ set color gray ]
  reset-ticks
end


to setup-sceen-size
  ifelse using-small-screen = True [
    set-patch-size 8
  ][
    set-patch-size 12
  ]

end

to setup-people
  set-default-shape people "person"
  create-people number-of-people
  [
    setxy (random-xcor * 0.95) (random-ycor * 0.95) ; position people avoiding the edge
    set belief 0 ;; defaulting that they dont have a belief in the theory
    set color white
    set influenceable random-float 1 ;; gets a value 0 < pers < 1
    set news-trust? false
;;    become-susceptible
;;    set virus-check-timer random virus-check-frequency
  ]
end

to setup-news
  create-sources 1[
    setxy 0 0
    set color green
    set shape "house"
    create-ss-ps-with n-of news-trust people [set color green] ;; creates links between news-trust people and the news
  ]
end


to setup-friends-network
  let num-links (average-friends * number-of-people) / 2
  while [count links < num-links ]
  [
    ask one-of people
    [
      let choice (min-one-of (other people with [not link-neighbor? myself])
                   [distance myself])
      if choice != nobody [ create-p-p-with choice ]
    ]
  ]
  ;; even out the networrk spacing
  repeat 100 [ layout-spring people links 0.3 (world-width / (sqrt number-of-people)) 1 ]
end



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; GO ;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go
  ;; stop condition
  ;; update stats
  if ticks > 100 [
    print ( "No real stopping condition")
    stop
  ]
  if all? people [belief = 100] [stop]
  ;; let people spread the rumor
  ask people
  [
    receive-rumor
    set color scale-color red belief 200 0
  ]
  ;; sends out the news
  ask sources [
    send-news
  ]

  ;; pusing peole closer to likeminded people
  ask people
  [
    do-layout   ;; getting closer to the likeminded people
  ]
  new-friends-network
  tick
end


;; if you watch the news your belief gets droped by 10%
to send-news
  let reduction-through-news 0.9
  ask s-p-neighbors
  [
    set belief belief * reduction-through-news
  ]
end



to receive-rumor
  let t1-belief belief ;; the belief of the cur turtle
  let n-p-p-neighbors count p-p-neighbors
  let t-id who ;; the id of the cur turtle

  ;; so we dont divide by 0
  if n-p-p-neighbors = 0 [ stop ]


  ;; creates a list of the beliefs and distances for each connected turtle
  let list-distance (list)
  let list-belief (list)
  let list-nom (list)

  ;; the total outer imact
  let outer-impact 0


  ask p-p-neighbors
  [
    let dist [distance turtle t-id] of turtle who
    set list-distance lput dist list-distance ;; collect the distance between cur and linked turtle
    set list-belief lput belief list-belief ;; collect the belief of linked turtle

  ]


  let i 0
  let sum-distance sum(list-distance)
  let weight-i 0

  let nom 0


  ;;;;;;;;;; formula of own belief ;;;;;;;;;;;;
  ; own-belief = own-belief * (1-influencability) + frinds-belief * (influencability)
  ; friends-belief = sum(friend-belief)
  ; friend-belief-i = (sum(distances) - distance-i) / sum(sum(distances) - distance-i))

  while[ i  < n-p-p-neighbors]
  [
    set nom sum-distance - (item i list-distance)
    set list-nom lput nom list-nom ;; collect the belief of linked turtle
    set i (i + 1)
  ]

  set i 0
  let sum-nom sum(list-nom)
  if sum-nom = 0 [ stop ]
  while [i < n-p-p-neighbors]
  [
    set weight-i (( item i list-nom ) / sum-nom) ;; the weight of linked turtle i
    set outer-impact outer-impact + weight-i * (item i list-belief ) ;; adjusting the outer imact
    ;; increment index
    set i i + 1

  ]
  ;; doing a bit of radicalisation
  let radical (outer-impact - 50) * 0.05

  ;; keeping it in the bouds [0,100]
  set outer-impact (min list 100 (radical + outer-impact))
  set outer-impact (max list 0 outer-impact)

  set belief (belief * (1 -  influenceable) +  outer-impact * influenceable)

end


to new-friends-network
  ask ps-ps [ die] ;; kills all the ps-ps connection to sez thrm up newly
  let num-links (average-friends * number-of-people) / 2
  while [count links < num-links ]
  [
    ask one-of people
    [
      let choice (min-one-of (other people with [not link-neighbor? myself])
                   [distance myself])
      if choice != nobody [ create-p-p-with choice ]
    ]
  ]

end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;; LAYOUT ;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to do-layout
  let t-id who
  let b1 belief
  let min-dist 2 ;; min distance between to neighbors

  ask p-p-neighbors[

    let dist [distance turtle t-id] of turtle who ;; get the distance between connected turtles

    let diff (b1 - belief) / 100 ;; difference in belief

    ;; make taut the distance between the believes
    if diff < 0 [ set diff diff * -1]
    let tvl-dist (0.5 - diff)


    ;;let target turtle t-id
    face turtle t-id

    ;; to maintain a bit of distance, for nicer visualisation
    ifelse dist < min-dist [
      fd dist - min-dist
    ][
      fd tvl-dist
    ]
  ]
  display
end
@#$#@#$#@
GRAPHICS-WINDOW
265
125
1005
866
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
-30
30
-30
30
1
1
1
ticks
30.0

BUTTON
20
610
250
650
Setup
setup
NIL
1
T
OBSERVER
NIL
S
NIL
NIL
1

BUTTON
20
660
250
700
Go
go
T
1
T
OBSERVER
NIL
G
NIL
NIL
0

SLIDER
20
385
250
418
number-of-people
number-of-people
50
1000
100.0
50
1
people
HORIZONTAL

SLIDER
20
465
250
498
percent-misinformed
percent-misinformed
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
20
425
250
458
average-friends
average-friends
1
(number-of-people / 4) - 1
15.0
1
1
per person
HORIZONTAL

BUTTON
20
160
247
193
South Korea
set number-of-people 500\nset average-friends 15\nset percent-misinformed 50\nset news-trust 21\nsetup
NIL
1
T
OBSERVER
NIL
1
NIL
NIL
1

TEXTBOX
15
130
165
148
Presets
14
0.0
0

TEXTBOX
15
365
165
383
Custom
14
0.0
1

BUTTON
20
200
247
233
United States of America
set number-of-people 500\nset average-friends 15\nset percent-misinformed 50\nset news-trust 29\nsetup
NIL
1
T
OBSERVER
NIL
2
NIL
NIL
1

BUTTON
20
280
247
313
Netherlands
set number-of-people 500\nset average-friends 15\nset percent-misinformed 50\nset news-trust 52\nsetup
NIL
1
T
OBSERVER
NIL
4
NIL
NIL
1

BUTTON
20
320
247
353
Finland
set number-of-people 500\nset average-friends 15\nset percent-misinformed 50\nset news-trust 56\nsetup
NIL
1
T
OBSERVER
NIL
5
NIL
NIL
1

TEXTBOX
275
35
1015
131
Influence of Fact-Checked News Media on the Spread of Misinformation Model
28
0.0
1

TEXTBOX
15
10
240
111
You can either choose a preset or choose your own values, if you choose custom values you need to click Setup.\n\nThen to run click Go.
14
0.0
1

SWITCH
20
545
250
578
using-small-screen
using-small-screen
1
1
-1000

SLIDER
20
505
250
538
news-trust
news-trust
0
number-of-people
56.0
1
1
%
HORIZONTAL

PLOT
20
725
250
935
Spread on Misinformation
Ticks
Percent of Population
0.0
100.0
0.0
100.0
false
true
"" ""
PENS
"Misinformed" 1.0 0 -2674135 true "" "plot (count people with [belief > 50] / count people) * 100"
"Correct" 1.0 0 -13345367 true "" "plot (count people with [belief <= 50] / count people) * 100"

MONITOR
265
875
422
936
Misinformed People
count people with [belief > 50]
1
1
15

MONITOR
435
875
642
936
Correctly Informed People
count people with [belief <= 50]
0
1
15

BUTTON
20
240
248
273
Middle Value
set number-of-people 500\nset average-friends 15\nset percent-misinformed 50\nset news-trust 38.5\nsetup
NIL
1
T
OBSERVER
NIL
3
NIL
NIL
1

@#$#@#$#@
# Conspiracy Theories - C34
## WHAT IS IT?

This model demonstrates the spread of misinformation through a population, and the impact of a trusted fact-check news media can have in its spread.

## HOW IT WORKS
Each time step (tick), each node will try to convice the connected nodes of its own `belief`. Each node has a `belief` and also an incluenability which tetermiens how much a a node will be influenced by neighbors per tick. The more the node beliefs in a theory the more red the node becommes. Initial beliefers of a theory will be displayed as a sheep. This only helps as a representation and is not used afterwards. 

Each node will also adjust his position to its belief. If there are two nodes which share a similar belied they will move closer towards eachother. This will lead to a clustering of nodes having a similar belief. Additionally, there is a radicallisation happening which happens when the neighbors are all strongly believing or strongly not believing in a theory. This will lead to the clusters, without news impact will either belief or dispelief a theory completely. 



## HOW TO USE IT

Using the sliders, choose the NUMBER-OF-NODES and the AVERAGE-NODE-DEGREE (average number of links coming out of each node).

The network that is created is based on proximity (Euclidean distance) between nodes.  A node is randomly chosen and connected to the nearest node that it is not already connected to.  This process is repeated until the network has the correct number of links to give the specified average node degree.

The INITIAL-OUTBREAK-SIZE slider determines how many of the nodes will start the simulation infected with the virus.

Then press SETUP to create the network.  Press GO to run the model.  The model will stop running once the virus has completely died out.

The VIRUS-SPREAD-CHANCE, VIRUS-CHECK-FREQUENCY, RECOVERY-CHANCE, and GAIN-RESISTANCE-CHANCE sliders (discussed in "How it Works" above) can be adjusted before pressing GO, or while the model is running.

The NETWORK STATUS plot shows the number of nodes in each state (S, I, R) over time.

## THINGS TO NOTICE

At the end of the run, after the virus has died out, some nodes are still susceptible, while others have become immune.  What is the ratio of the number of immune nodes to the number of susceptible nodes?  How is this affected by changing the AVERAGE-NODE-DEGREE of the network?

## THINGS TO TRY

Set GAIN-RESISTANCE-CHANCE to 0%.  Under what conditions will the virus still die out?   How long does it take?  What conditions are required for the virus to live?  If the RECOVERY-CHANCE is bigger than 0, even if the VIRUS-SPREAD-CHANCE is high, do you think that if you could run the model forever, the virus could stay alive?
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

sheep 2
false
0
Polygon -7500403 true true 209 183 194 198 179 198 164 183 164 174 149 183 89 183 74 168 59 198 44 198 29 185 43 151 28 121 44 91 59 80 89 80 164 95 194 80 254 65 269 80 284 125 269 140 239 125 224 153 209 168
Rectangle -7500403 true true 180 195 195 225
Rectangle -7500403 true true 45 195 60 225
Rectangle -16777216 true false 180 225 195 240
Rectangle -16777216 true false 45 225 60 240
Polygon -7500403 true true 245 60 250 72 240 78 225 63 230 51
Polygon -7500403 true true 25 72 40 80 42 98 22 91
Line -16777216 false 270 137 251 122
Line -16777216 false 266 90 254 90

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
NetLogo 6.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="test" repetitions="1" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [belief &gt; 50]</metric>
    <enumeratedValueSet variable="using-small-screen">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-misinformed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-friends">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="news-trust">
      <value value="21"/>
      <value value="29"/>
      <value value="38.5"/>
      <value value="52"/>
      <value value="56"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="100 reps" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <metric>count turtles with [belief &gt; 50]</metric>
    <enumeratedValueSet variable="using-small-screen">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="percent-misinformed">
      <value value="50"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="number-of-people">
      <value value="500"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="average-friends">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="news-trust">
      <value value="21"/>
      <value value="29"/>
      <value value="38.5"/>
      <value value="52"/>
      <value value="56"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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
