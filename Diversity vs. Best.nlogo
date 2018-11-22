turtles-own [
  cog-skill ;cognitive skill usually equates to critical thinking and analytical abilities
  peo-skill ;people skill usually equates to communication efficiency and emotional intelligence
  perspective ;perspective usually correlates with people's biological characteristics, life experience and culture.
  team ;indicate which team the turtle is in. 0 is not in any team. team1 is on the left, team2 is on the right.
  ]

globals 
[
  debug 
  person-size
  pool-floor 
  view-width 
  team1-cog
  team1-peo
  team2-cog
  team2-peo
  task-cog
  task-peo
  task-perspectives
  team1-task-time
  team2-task-time
  task-circle
  team1-perspectives
  team2-perspectives
  num-tasks1
  num-tasks2
  average_time_per_task_diverse_team
  average_time_per_task_best_team 
  diversity-index1 
  cognitive-index1
  diversity-index2
  cognitive-index2 
  distance-per-move-up 
  quali-time
  quali-time2
  quanti-time
  quanti-time2
  quali-time-list
  quali-time-list2
  quanti-time-list
  quanti-time-list2
  
  ;task-list ;store all characteristics of the task 
  ;tasks-list ;store all the tasks
]


to go
  ;if (debug) [show [ycor] of turtles with [ycor > pool-floor]]
  if any? turtles with [ycor = max-pycor] [ ;[ycor] of one-of turtles with [team = 1] = 12.5 [ 
    report-final-stats 
    set average_time_per_task_diverse_team (ticks / num-tasks1)
    set average_time_per_task_best_team (ticks / num-tasks2) 
    stop] 
  do-interaction  
  tick 
end

to initialize 
  clear-all 
  initialize-globals 
  setup-visual
  if (debug) [show (word "now setup candidates")]
  setup-candidates
  if (debug) [show (word "now setup current teams")]
  setup-current-teams
  ;setup-new-task
  reset-ticks
end 

to initialize-globals 
  set debug false 
  set person-size 2
  set pool-floor round (max-pycor * 0.2) ;pool floor is 10 
  set view-width 48
  set team1-cog []
  set team1-peo []
  set team2-cog []
  set team2-peo []
  set task-cog 0
  set task-peo 0
  set task-circle 7 ;since perspectives are from 1 - 5, 7 is the best task-circle number that gives all numbers different num-steps to find solutions
  set task-perspectives []
  set team1-task-time 0
  set team2-task-time 0
  set team1-perspectives []
  set team2-perspectives []
  set num-tasks1 0
  set num-tasks2 0 
  set average_time_per_task_diverse_team 0
  set average_time_per_task_best_team 0
  set distance-per-move-up 0.5 
  set quali-time 0
  set quali-time2 0
  set quanti-time 0 
  set quanti-time2 0
  set quali-time-list []
  set quali-time-list2 []
  set quanti-time-list []
  set quanti-time-list2 []
  ;set task-list []
  ;set tasks-list [] 
end 

to setup-visual 
  ask patches with [pycor = pool-floor + 1]
  [set pcolor white] 
  ask patches with [pxcor = view-width / 2 and pycor > pool-floor + 1]
  [set pcolor white] 
end 

to setup-candidates 
   create-turtles 200 
   [
    set cog-skill (random 5) + 1 ;+1 is to set the start value as 1 rather than 0 to avoid it being divided as 0 later (also just cognitively easier to think about) 
    set peo-skill (random 5) + 1
    set team 0
    set xcor (random (view-width - 1)) + 1
    set ycor (random (pool-floor - 1)) + 1 
    set size person-size  
    set shape "person" ; set the correct shape based on pose/direction
    set heading 360
   ]
   
   ; assume cog-skill has some biases on what perspectives the person will had taken on  
   ask turtles with [cog-skill < 3] [
     set perspective (round (random-normal 1 0.5)) + 1 ;normal distribution around 2
     if perspective > 5 [ ;if the perspective choosen from the distribution is greater than the limit, choose it again until it's within the limit  
       set perspective 5 ]
     if perspective < 1 [
       set perspective 1]
   ]
   
   ask turtles with [cog-skill > 3] [
     set perspective (round (random-normal 3 0.5)) + 1 ;questionable to use normal distribution since each perspective has different average time. 
     if perspective > 5 [ ;if the perspective choosen from the distribution is greater than the limit, choose it again until it's within the limit  
       set perspective 5]
     if perspective < 1 [
       set perspective 1]
   ]
   
   ask turtles with [cog-skill = 3] [
     set perspective random 5 + 1
   ] 
   
end
;randomly select 5 turtles in the pool
to setup-current-teams  
  let winner 0 
  let x-position 1 
  ;assume now team1 is the control group that is randomly selected 
  if Team1 = "random selection" [
    repeat 5 [ 
      set winner one-of turtles with [ycor < pool-floor] 
      ask winner [
        set team 1 
        set xcor x-position 
        set ycor pool-floor + 2 
        set team1-cog lput [cog-skill] of winner team1-cog
        set team1-peo lput [peo-skill] of winner team1-peo 
        set team1-perspectives lput [perspective] of winner team1-perspectives 
      ]
      set x-position x-position + 5
    ]
  ]

;select turtles one-by-one which has different perspectives of the current team members 
  if Team1 = "diverse" [
    set x-position 1 
    repeat 5 [
      set winner one-of turtles with [ycor < pool-floor and (is-unique? perspective team1-perspectives)]
      if winner = nobody [show (word "team1-per is " team1-perspectives " and per are " [perspective] of turtles with [ycor < pool-floor])]
      ask winner [
        set team 1
        set xcor x-position 
        set ycor pool-floor + 2
        set team1-cog lput [cog-skill] of winner team1-cog
        set team1-peo lput [peo-skill] of winner team1-peo 
        set team1-perspectives lput [perspective] of winner team1-perspectives 
      ]
    set x-position x-position + 5
    ]
  ]
  
 ;select turtles one-by-one with different perspectives and >= 3 cog-skills
  if Team1 = "high tech and diverse" [
    set x-position 1 
    repeat 5 [
      set winner one-of turtles with [ycor < pool-floor and (is-unique? perspective team1-perspectives) and cog-skill >= 3]
      if winner = nobody [show (word "team1-per is " team1-perspectives " and per are " [perspective] of turtles with [ycor < pool-floor])]
      ask winner [
        set team 1
        set xcor x-position 
        set ycor pool-floor + 2
        set team1-cog lput [cog-skill] of winner team1-cog
        set team1-peo lput [peo-skill] of winner team1-peo 
        set team1-perspectives lput [perspective] of winner team1-perspectives 
      ]
    set x-position x-position + 5
    ] 
  ]
  
  ;select 4 people with high cog skills and 1 person to complement diversity 
  if Team1 = "high tech and partially diverse" [
    set x-position 1 
    repeat 4 [
      set winner one-of turtles with [ycor < pool-floor and cog-skill >= 4] ;max-one-of (n-of 5 turtles with [ycor < pool-floor]) [cog-skill]
      ;if winner = nobody [show (word "team1-per is " team1-perspectives " and per are " [perspective] of turtles with [ycor < pool-floor])]
      ask winner [
        set team 1
        set xcor x-position 
        set ycor pool-floor + 2
        set team1-cog lput [cog-skill] of winner team1-cog
        set team1-peo lput [peo-skill] of winner team1-peo 
        set team1-perspectives lput [perspective] of winner team1-perspectives 
      ]
    set x-position x-position + 5
    ]
    repeat 1 [
      set winner one-of turtles with [ycor < pool-floor and (is-unique? perspective team1-perspectives)]
      ask winner [
        set team 1
        set xcor x-position 
        set ycor pool-floor + 2
        set team1-cog lput [cog-skill] of winner team1-cog
        set team1-peo lput [peo-skill] of winner team1-peo 
        set team1-perspectives lput [perspective] of winner team1-perspectives 
      ]
    ]
  ]
  if (debug) [show (word "team1-cog is " team1-cog " team1-peo is " team1-peo " team1-perspectives are " team1-perspectives)]     
  
  
  ;;;;;;;;;;;;;;;;;;;;;;;;TEAM2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  ;allow audience to select various hiring policies for team2
  if team2 = "random selection" [
    set x-position 1   
    repeat 5 [
      set winner one-of turtles with [ycor < pool-floor] 
      ask winner [
        set team 2 
        set xcor (view-width / 2) + 1 + x-position 
        set ycor pool-floor + 2 
        set team2-cog lput [cog-skill] of winner team2-cog
        set team2-peo lput [peo-skill] of winner team2-peo 
        set team2-perspectives lput [perspective] of winner team2-perspectives 
      ]
      set x-position x-position + 5
    ]
    if (debug) [show (word "team2-cog is " team2-cog " team2-peo is " team2-peo " team2-perspectives are " team2-perspectives)]
  ]
  
  if Team2 = "high tech skills" [
    set x-position 1
    repeat 5 [
      set winner one-of turtles with [ycor < pool-floor and cog-skill >= 4]
      ask winner [
        set team 2 
        set xcor (view-width / 2) + 1 + x-position  
        set ycor pool-floor + 2 
        set team2-cog lput [cog-skill] of winner team2-cog
        set team2-peo lput [peo-skill] of winner team2-peo 
        set team2-perspectives lput [perspective] of winner team2-perspectives  
      ]
      set x-position x-position + 5
    ]
  ]
  
  if Team2 = "low tech and not diverse" [
    set x-position 1 
    repeat 5 [
      set winner one-of turtles with [ycor < pool-floor and (not (is-unique? perspective team1-perspectives)) and cog-skill <= 3]
      if winner = nobody [show (word "team1-per is " team1-perspectives " and per are " [perspective] of turtles with [ycor < pool-floor])]
      ask winner [
        set team 2 
        set xcor (view-width / 2) + 1 + x-position  
        set ycor pool-floor + 2 
        set team2-cog lput [cog-skill] of winner team2-cog
        set team2-peo lput [peo-skill] of winner team2-peo 
        set team2-perspectives lput [perspective] of winner team2-perspectives  
      ]
    set x-position x-position + 5
    ]
  ]
 
    if (debug) [show (word "team2-cog is " team2-cog " team2-peo is " team2-peo " team2-perspectives are " team2-perspectives)]
  

end 

;to do-interaction 
     
to setup-new-task 
  if Tasks-type = "random" [
    set task-perspectives []
    set task-cog random 5 + 1 
    set task-peo random 5 + 1 
    repeat (random 5) + 1 [ 
      set task-perspectives lput ((random 5) + 1) task-perspectives]
    repeat (random 5) + 1 [
    if (debug) [show (word "the new task is " task-cog " " task-peo task-perspectives)]]
  ]
  
  if Tasks-type = "diverse" [
    set task-perspectives []
    set task-cog random 5 + 1 
    set task-peo random 5 + 1 
    repeat (random 2) + 4 [ 
      let task-perspective (random 5) + 1
      while [not (is-unique? task-perspective task-perspectives)] [ ;sample perspectives until it's unique to the task-perspective list
        set task-perspective (random 5) + 1 ]
      set task-perspectives lput task-perspective task-perspectives] 
    if (debug) [show (word "the new task is " task-cog task-peo task-perspectives)]
  ]
  
  if Tasks-type = "high tech skills" [
    set task-perspectives []
    set task-cog random 1 + 4 
    set task-peo random 5 + 1  
    repeat (random 5) + 1 [ 
      set task-perspectives lput ((random 5) + 1) task-perspectives]
    if (debug) [show (word "the new task is " task-cog " " task-peo task-perspectives)]
  ]
  
  if Tasks-type = "high tech and diverse" [ ;task-tech >= 4 and require at least 4 perspectives
    set task-perspectives []
    set task-cog random 1 + 4 
    set task-peo random 5 + 1  
    repeat (random 2) + 4 [ 
      let task-perspective (random 5) + 1
      while [not (is-unique? task-perspective task-perspectives)] [
        set task-perspective (random 5) + 1 ]
      set task-perspectives lput task-perspective task-perspectives]
    if (debug) [show (word "the new task is " task-cog " " task-peo task-perspectives)]
  ]
  
  if Tasks-type = "low diversity" [
    set task-perspectives []
    set task-cog random 5 + 1 
    set task-peo random 5 + 1 
    repeat (random 5) + 1 [ 
      set task-perspectives lput ((random 3) + 3) task-perspectives] 
    if (debug) [show (word "the new task is " task-cog " " task-peo task-perspectives)]
  ]
  
  if Tasks-type = "low tech skills" [
    set task-perspectives []
    set task-cog random 2 + 1 
    set task-peo random 5 + 1 
    repeat (random 5) + 1 [ 
      set task-perspectives lput ((random 5) + 1) task-perspectives] 
    if (debug) [show (word "the new task is " task-cog " " task-peo task-perspectives)]
  ]
  

end 

;to setup-all-tasks
  ;repeat (max-pycor - (pool-floor + 2)) / distance-per-move-up [
    ;setup-new-task ]
    

to do-interaction 
  if team1-task-time <= 0 [
    if (debug) [show (word "team1-cog is " team1-cog " team1-peo is " team1-peo " team1-perspectives are " team1-perspectives)]
    setup-new-task 
    let team1-task-time-list []
    let perspectives-time-list [] ;this is used for both team1 and team2. It contains a list of time for each member to find one of the perspective solution 
    let perspectives-least-time-list [] ;it's a list of least amount of time used to find each perspective solution 
    let perspectives-least-time 0
    
    ;;;;;;;Technical Skills;;;;;;;;;;;;;;;;;;;;;;;;; 
    let cog-time 25 - (mean team1-cog - task-cog) * 6.35 ;mean of quali time is 25 and 6.35
    if cog-time < 5 [
      set cog-time (5 + (random-float 3 - random-float 3))] ;in case std extends over range, set 5 as minimum. 
    set team1-task-time-list lput (cog-time + (random-float 5 - random-float 5)) team1-task-time-list ;25 is the mu of quali-time distribution while 11 is the sigma
  
    ;;;;;;;Perspectives;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    foreach task-perspectives [
      set perspectives-time-list []
      ask turtles with [team = 1] [
        set perspectives-time-list lput (least-time (perspective) (task-circle) (?)) perspectives-time-list ;create a list of time that each member in the team use to find the perspective position in the task
        
        ;if (debug) [show (word "perspectives-time-list for one perspective solution is" perspectives-time-list)]
        if length perspectives-time-list = 5 [ ;only start when the list have contained all members' (5) time to find the perspective solution
          set perspectives-least-time-list lput (first (sort-by < perspectives-time-list)) perspectives-least-time-list;store the shortest time to find each perspective solution
        ] 
      ]
    ]
    ;if (debug) [show (word "there is/are " (length perspectives-least-time-list) " perspective solution(s) and the shortest time for each is " perspectives-least-time-list)]
    
    ; add the sum of time that is used on finding perspective(s) solution to the team-task-time list so that we can compare and find the max as the overall finished time for this team on this task
    set team1-task-time-list lput (sum perspectives-least-time-list) team1-task-time-list 
    
    ;;;;;;;People Skills;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      
    let peo-time 25 - (mean team1-peo - task-peo) * 6.35
    if peo-time < 5 [
      set peo-time (5 + (random-float 3 - random-float 3))]
    ; if people's skills are not enough, then it will induce cost to diversity. One unit of cost to diversity is the same as one unit cost of high ability on perspective running time 
    if peo-time < 3 [
      set perspectives-least-time ((sum perspectives-least-time-list) + (peo-time - 3) * 4.2)]
    if peo-time >= 3 [
      set perspectives-least-time (sum perspectives-least-time-list)]
    
    set team1-task-time-list lput (perspectives-least-time) team1-task-time-list
      
     
    ;set team1-task-time-list lput (peo-time + (random-float 3 - random-float 3)) team1-task-time-list
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    set quali-time-list lput (sum perspectives-least-time-list) quali-time-list
    set quanti-time-list lput (round cog-time) quanti-time-list
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    
    if (debug) [show (word "team1's time to finish each requirements" team1-task-time-list)]
  
    set team1-task-time first (sort-by > team1-task-time-list) ; team1-task-time is defined by longest time of the four (cog, peo, perspective) to meet the requirements   
    
  ]
  
  if team1-task-time > 0 [
    if (debug) [show (word "team1 still need " team1-task-time " ticks to finish the task ")]
    set team1-task-time team1-task-time - 1 ]
  
  if team1-task-time <= 0 [
    if (debug) [ show (word "Team1's task is finished")]
    move-up ] 
  
;let team2 interacts with the task. same code as team1
 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;TEAM2;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  if team2-task-time <= 0 [
    if (debug) and (team2 = "high-cog-skills") [show (word "team2-cog is " team2-cog " team2-peo is " team2-peo " team2-perspectives are " team2-perspectives)]
    setup-new-task 
    let team2-task-time-list []
    let perspectives-time-list [] ;this is used for both team1 and team2. It contains a list of time for each member to find one of the perspective solution 
    let perspectives-least-time-list [] ;it's a list of least amount of time used to find each perspective solution 
    let perspectives-least-time 0
     
    ;;;;;;;;;;;;;;;;;;;;Technical Skills;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    let cog-time 25 - (mean team2-cog - task-cog) * 6.35
    if cog-time < 5 [
      set cog-time (5 + (random-float 5 - random-float 5))]
    set team2-task-time-list lput (cog-time + (random-float 5 - random-float 5)) team2-task-time-list ;25 is the mu of quali-time distribution while 11 is the sigma
    
    ;;;;Perspectives;;;;;;;;;
  
    foreach task-perspectives [
      set perspectives-time-list []
      ask turtles with [team = 2] [
        set perspectives-time-list lput (least-time (perspective) (task-circle) (?)) perspectives-time-list ;create a list of time that each member in the team use to find the perspective position in the task
        
        ;if (debug) [show (word "perspectives-time-list for one perspective solution is" perspectives-time-list)]
        if length perspectives-time-list = 5 [ ;only start when the list have contained all members' (5) time to find the perspective solution
          set perspectives-least-time-list lput (first (sort-by < perspectives-time-list)) perspectives-least-time-list;shortest time to find each perspective solution
        ] 
      ]
    ]
    if (debug) [show (word "there is/are " (length perspectives-least-time-list) " perspective solution(s) and the shortest time for each is " perspectives-least-time-list)]
    
    ;;;;;;;;;;;;;;;;;;People Skills;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    let peo-time 25 - (mean team2-peo - task-peo) * 6.35
    if peo-time < 5 [
      set peo-time (5 + (random-float 5 - random-float 5))]
    set team2-task-time-list lput (peo-time + (random-float 5 - random-float 5)) team2-task-time-list
    
    if peo-time < 3 [
      set perspectives-least-time ((sum perspectives-least-time-list) + (peo-time - 3) * 4.2)]
    if peo-time >= 3 [
      set perspectives-least-time (sum perspectives-least-time-list)]
    
    set team2-task-time-list lput (perspectives-least-time) team2-task-time-list
    ; add the sum of time that is used on finding perspective(s) solution to the team-task-time list so that we can compare and find the max as the overall finished time for this team on this task
    ;set team2-task-time-list lput (sum perspectives-least-time-list) team2-task-time-list 
    
    ;;;;;;;;;;;
    set quali-time-list2 lput (sum perspectives-least-time-list) quali-time-list2
    set quanti-time-list2 lput (round cog-time) quanti-time-list2
    ;;;;;;;;;;;;
    
    if (debug) [show (word "team2's time to finish each requirements" team2-task-time-list)]
  
    set team2-task-time first (sort-by > team2-task-time-list) 
  ]
  
  if team2-task-time > 0 [
    if (debug) [show (word "team2 still need " team2-task-time " ticks to finish the task ")]
    set team2-task-time team2-task-time - 1 ]
  
  if team2-task-time <= 0 [
    if (debug) [ show (word "Team2's task is finished")]
    move-up2 ] 
end  
   
to move-up
  ask turtles with [team = 1] [
    set ycor ycor + distance-per-move-up ] ;it's a bit cheating, but max-pycor is 48, which means if I keep adding 4, it will reach the top rather than go over the top 
end 

to move-up2
  ask turtles with [team = 2] [
    set ycor ycor + distance-per-move-up ] ;it's a bit cheating, but max-pycor is 48, which means if I keep adding 4, it will reach the top rather than go over the top 
end 

to-report is-unique? [number lst]
  report not member? number lst
end

to-report least-time [steps-per-time tsk-circle solution-position]
  let k 0
  while [(tsk-circle * k + solution-position) mod steps-per-time != 0] [
    set k k + 1 ]
  ifelse steps-per-time != 1 [
    report (tsk-circle * k + solution-position) / steps-per-time * 5 ];aligning the range from [1 6] to [5 30] 
  [ report (tsk-circle * k + solution-position) / steps-per-time * 6 ];aligning the range from [1 5] to [6 30] 
end 
      

to-report frequency [i lst]
  report length filter [? = i] lst 
end 

to-report calculate-diversity-index [team-perspectives] ;Diversity Index [1 5] 
  let div-perspective [] 
  foreach [0 1 2 3 4] [
    set div-perspective lput frequency (item ? team-perspectives) team-perspectives div-perspective
  report 5 - (mean div-perspective)
  ]  ;the max diversity-index is 5 
end 
  
to report-final-stats 
  set quali-time mean (quali-time-list) 
  set quali-time2 mean (quali-time-list2)
  set quanti-time mean(quanti-time-list) 
  set quanti-time2 mean(quanti-time-list2)
  set num-tasks1 ([ycor] of one-of turtles with [team = 1] - (pool-floor + 2)) / distance-per-move-up  
  set num-tasks2 ([ycor] of one-of turtles with [team = 2] - (pool-floor + 2)) / distance-per-move-up  
  ; how to count how many are different from each other. if 5, diversity 
  
  set diversity-index1 (calculate-diversity-index team1-perspectives)
  set cognitive-index1 mean team1-cog
  
  set diversity-index2 (calculate-diversity-index team2-perspectives)
  set cognitive-index2 mean team2-cog  
  
  show ( "" )
  show ( word "-------- FINAL STATISTICS --------" )
  
  show (word " Team1's stats are " team1-cog " " team1-peo " " team1-perspectives " ")
  show (word " Team2's stats are " team2-cog " " team2-peo " " team2-perspectives " ")
  show (word " Team1's diversity index is " diversity-index1 " and cognitive-index is " cognitive-index1)
  show (word " Team2's diversity index is " diversity-index2 " and cognitive-index is " cognitive-index2)
  show (word " Team1 finish " num-tasks1 " tasks in  ticks " ticks )
  show (word " Team2 finish " num-tasks2 " tasks in  ticks " ticks )
  show (word " Quali-time for team1 is " quali-time)
  show (word " Quanti-time for team1 is " quanti-time)
  show (word " Quali-time for team2 is " quali-time2)
  show (word " Quanti-time for team2 is " quanti-time2)
end  


;one unit change in cog-diversity -> 4.2 unit of time (1.5 cog-diversity from random to high tech, and 6.3 change of perspective time) 
  
@#$#@#$#@
GRAPHICS-WINDOW
186
10
621
466
-1
-1
8.6735
1
10
1
1
1
0
1
1
1
0
48
0
48
1
1
1
ticks
30.0

BUTTON
10
16
92
49
Initialize
initialize
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
105
17
168
50
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

CHOOSER
9
61
168
106
Team1
Team1
"random selection" "diverse" "high tech and diverse" "high tech and partially diverse"
1

CHOOSER
9
110
168
155
Team2
Team2
"random selection" "high tech skills" "low tech and not diverse"
1

CHOOSER
9
159
168
204
Tasks-type
Tasks-type
"random" "diverse" "high tech skills" "high tech and diverse" "low diversity" "low tech skills"
0

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

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

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270

@#$#@#$#@
NetLogo 5.2.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="average-time-per-task" repetitions="1000" runMetricsEveryStep="false">
    <setup>Initialize</setup>
    <go>Go</go>
    <metric>average_time_per_task_diverse_team</metric>
    <metric>average_time_per_task_best_team</metric>
    <enumeratedValueSet variable="Team1">
      <value value="&quot;high tech and partially diverse&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team2">
      <value value="&quot;low tech and not diverse&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tasks-type">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Diversity-index and Cog-index" repetitions="1000" runMetricsEveryStep="false">
    <setup>Initialize</setup>
    <go>Go</go>
    <metric>diversity-index1</metric>
    <metric>diversity-index2</metric>
    <metric>cognitive-index1</metric>
    <metric>cognitive-index2</metric>
    <enumeratedValueSet variable="Team1">
      <value value="&quot;high tech and diverse&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team2">
      <value value="&quot;random-selection&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Tasks-type">
      <value value="&quot;diverse&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="1000-quali-time" repetitions="1000" runMetricsEveryStep="false">
    <setup>Initialize</setup>
    <go>Go</go>
    <metric>quali-time2</metric>
    <enumeratedValueSet variable="Tasks-type">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team2">
      <value value="&quot;high tech skills&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team1">
      <value value="&quot;random selection&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="1000-quanti-time" repetitions="1000" runMetricsEveryStep="false">
    <setup>Initialize</setup>
    <go>Go</go>
    <metric>quanti-time</metric>
    <enumeratedValueSet variable="Tasks-type">
      <value value="&quot;random&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team2">
      <value value="&quot;random-selection&quot;"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Team1">
      <value value="&quot;random-selection&quot;"/>
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
