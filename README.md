# Final Project of the Course Agent Technology 
Created by:\
Lawrence Fulton - s3599523 \
Darren Rawlings - s3612309 \
Tim Chandler - s3173593\
Bogdan Chelu - s3355926


# Conspiracy Theories - C34
## WHAT IS IT?

This model demonstrates the spread of misinformation through a population, and the impact of a trusted fact-check news media can have in its spread.

## HOW IT WORKS
Each time step (tick), each node will try to convince the connected nodes of its own `belief`. Each node has a `belief` and also an influenceability which determines how much a a node will be influenced by neighbors per tick. The more the node beliefs in a theory the more red the node becomes. Initial believers of a theory will be displayed as a sheep and will be determined by the `percent-misinformed` value. The visualization of the sheep only helps as a representation and is not used afterwards further.

The number of neighbors each node has depends on the variable `average-friends`. Each neighbor is displayed with an edge between nodes. The number of agents in the simulation can be modified by the `number-of-people` variable. 

Each node will also adjust his position to its belief. If there are two nodes which share a similar belied they will move closer towards each other. This will lead to a clustering of nodes having a similar belief. Additionally, there is a radicalization happening which happens when the neighbors are all strongly believing or strongly not believing in a theory. This will lead to the clusters, without news impact will either belief or disbelief a theory completely. New friendships will also be created after each tick, favouring nodes which are connected closely, meaning that close nodes will likely to become friends, helping the reinforcing effect of the belief in a theory in small groups. 
One additional node, the news, is added in the center of the screen. This node would represent fact checked media. The variable `news-trust` determines how many people world watch the news and get influenced by it. 


## HOW TO USE IT

The previously mentioned variables can be changed by sliders. After changes in those variables have been done a click on the `setup` button will implement those. To run the model press on the `run` button. Several presets have been created and are based on the data from the Digital News Report (2020) by Reuters. 
