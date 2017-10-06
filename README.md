### AMPL CPLEX optimization solver

		Tung Thanh Le
		ttungl at gmail dot com

**Claims**

	This is one of my research projects. If you use this material, please cite the link below, I'd be appreciated.
	
	https://github.com/ttungl/AMPL-CPLEX-optimization-solver
		
---

**Task Scheduling Optimization in Distributed Computing Systems**

**Abstract**: As resources in distributed systems need to be efficiently exploited, the economic energy can be achieved. One of the challenges in resource allocation is task scheduling where tasks can be assigned optimally to gain a low energy consumption, high utilization, and low response time in term of fewer tasks cross the deadlines. In this work, we model a system with task scheduling problem as a max-sat problem and translate it into the integer linear programming (ILP) problem. From this translated problem, we use the optimization solvers to solve the problem. Our simulation results show that the tasks assigned on servers are optimal, leading to the high utilization in distributed systems. 


**I. Introduction**

Recently, distributed computing systems (DCS) are significantly dominated as its flexibility and availability. A DCS is a networking of groups of thousands of servers. Data-intensive crosses the system with the utilization of large number of processors. Assigning tasks efficiently in task scheduling is one of the challenges in distributed systems. An efficient task scheduling can gain the high utilization, low response time with few tasks meet the deadlines in distributed systems, resulting in improving the performance of the distributed systems. 

<img width="550" src="https://github.com/ttungl/AMPL-CPLEX-optimization-solver/blob/master/images/ampl1.png">

Figure 1: Task scheduling in a DCS.

In this work, we model the system with task scheduling problem as a max-sat problem, and translate it into ILP problem. From this translated problem, it is solved by using optimization solvers. The results demonstrate the tasks are assigned optimally on servers in different scenarios.  


**II. Modeling**

In this section, we model the system as follows.

Let `T` be a set of tasks `T = {T1, T2, …, Tn}` that needs to be assigned on servers. Each `Ti` is a completion time associated with its task `i`.  

Let S be a set of servers `S = {S1, S2, …, Sm}` as a resource that is utilized by tasks assignment. Each `Si` corresponds to the accessing time (deadline) on each server `i`.

Let `Xij` be a literal or a boolean variable denoting whether task `i` is assigned on server `j` or not. `Xij` is either `0` and `1`. 

A clause `C` is a disjunction of literals. A weighted clause is a pair `(C, w)` where `C` is a clause and `w` is a number (soft) or an infinity number (hard) indicating the penalty for falsifying the clause `C`. In our work, we can consider `w` as the tasks’ completion time.  

We have the weighted partial max-sat (WPMS) formula: 

	alpha = {(C1,w1), …, (Cn,wn)}

For max-sat problem, it is defined as:
	
	I{(C1,w1), …, (Cn,wn)} = sum{i=1,n} wi(1-I(Ci))

The optimal cost is: 

	cost(alpha) = {I(alpha) | I: var(alpha) -> {0,1}}, 
	
	where var(alpha) -> {0,1} is a function of a truth assignment for alpha. Thus, a WPMS problem is to find an optimal assignment.

<img width="550" src="https://github.com/ttungl/AMPL-CPLEX-optimization-solver/blob/master/images/ampl2.png">

Figure 2: Modeling of task scheduling on a DCS.

Thus, the objective function of the equivalent ILP can be described as follows.
 
	MINIMIZE sum{i in S, j in T} Xij * Tij

	s.t.

		sum{j in T} Xij*Tij <= Si, any i in S,

		sum{i in S} 0 <= Xij <= 1, any j in T.

To demonstrate how to translate a WPMS problem into ILP problem [1], we show an example as below.

A given WPMS problem:

	{(x1 v x2, 4), (x1 v <- x2, 9), (<-x1 v x2, inf), (<-x1 v <-x2, inf)}

Then we transform into `conjunctive normal form (CNF)` and `bi` is a decision variable. 

	ILP({CNF(<-b1 <-> (x1 v x2))}) 

	= ILP({CNF(<-b1 -> (x1 v x2), CNF((x1 v x2) -> <- b1)}) 

	= ILP({(x1 v x2 v b1), (<-x1 v <-b1), (<-x2 v <-b1)})

	= {(x1+x2+b1>0), ((1-x1)+(1-b1)>0), ((1-x2)+(1-b2)>0)} 

	= {(x1+x2+b1>0), (-x1-b1 > -2), -x2-b2 > -2)}

Do the same with other clauses, the corresponding ILP formulation is:

	MINIMIZE 4 * b1 + 9 * b2
	
	s.t.

		x1+x2+b1>0   

		-x1-b1>-2
		
		-x2-b1>-2
		
		x1-x2+b2>0
		
		-x1-b2>-2
		
		x2-b2>-1
		
		-x1+x2>-1
		
		-x1-x2>-2


where the bounds of literals and decision variables are in between `0` and `1`.

**III. Evaluation**

In this section, we apply the optimization solvers to solve the problem. We configure a specific scenario to demonstrate how it works [3]. Assume that we have a set of tasks including `5 tasks`, which will be assigned to a set of servers including `3 servers` as illustrated below.

<img width="350" src="https://github.com/ttungl/AMPL-CPLEX-optimization-solver/blob/master/images/ampl3.png">

Figure 3. An example.

|                 |  t1  |  t2  | t3   | t4   | t5   |
| :-------------: | :--: | :--: | :--: | :--: | :--: |
| completion time |  20  |  40  |  60  |  80  |  70  |



|         |  s6  |  s7  | s8   | 
| :-----: | :--: | :--: | :--: | 
| weight  |  80  |  100 |  90  | 



We use an online solver called neos-server [2] to solve the problem. We apply different solvers to solve the same problem, the results are as follows.

|   Solver   |  Gurobi  | XPRESS-MP|  CPLEX   |  Mosek          |  OOQP    |  
| :--------: | :------: | :------: | :------: | :-------------: | :------: |
| Assignment | t1 s7: 20| t1 s6: 20| t1 s7: 20|  t1 s6: 20      |  t1 s6: 4|  
| 			 | t2 s8: 40| t2 s8: 40| t2 s7: 30|  t2 s6: 10      |  t1 s7: 8|
| 			 | t3 s6: 30| t3 s7: 10| t2 s8: 10|  t2 s8: 29      |  t1 s8: 6|
| 			 | t3 s7: 30| t3 s8: 50| t3 s6: 30|  t3 s7: 50      |  t2 s6: 11|
| 			 | t4 s7: 30| t4 s6: 30| t3 s8: 30|  t3 s8: 10      |  t2 s7: 15|
| 			 | t4 s8: 50| t4 s7: 50| t4 s6: 50|  t4 s6: 29      |  t2 s8: 13|
| 			 | t5 s6: 50| t5 s6: 30| t4 s8: 30|  t4 s7: 3.55e-15|  t3 s6: 17|
| 			 | t5 s7: 20| t5 s7: 40| t5 s7: 50|  t4 s8: 50      |  t3 s7: 22|
| 			 |          |          | t5 s8: 20|  t5 s6: 20      |  t3 s8: 20|
| 			 |          |          |          |  t5 s7: 50      |  t4 s6: 24|
| 			 |          |          |          |                 |  t4 s7: 28|
| 			 |          |          |          |                 |  t4 s8: 26|
| 			 |          |          |          |                 |  t5 s6: 21|
| 			 |          |          |          |                 |  t5 s7: 25|
| 			 |          |          |          |                 |  t5 s8: 23|

			    
From the result as above, we can see that the tasks are assigned through the servers in different ways and it depends on the solving capability of each solver, yielding the different results. The less number of pairs utilized implicates the high utilization with low cost for assignments. 


<img width="550" src="https://github.com/ttungl/AMPL-CPLEX-optimization-solver/blob/master/images/ampl4.png">

Figure 4: Simulation result

**IV Conclusion**

We first modeled a system with task scheduling problem as a max-sat problem, then translated it into the integer linear programming (ILP) problem. We used the MIP solvers to solve the problem. Simulation results demonstrated that the tasks assigned on servers are optimal in several solvers (Gurobi, Xpress, CPLEX), leading to the high utilization in distributed systems. 

**References**

[1] C. Ansótegui, J. Gabàs, Solving (Weighted) Partial MaxSAT with ILP, CPAIOR2013.

[2] www.neos-server.org

[3] www.ampl.com 

**Source code**


**data.dat**
``` data.dat
#data;
set TASKset := 1 2 3 4 5;
set SERVERset := 6 7 8;
# source #total 270
param T_supply :=
1 20,
2 40,
3 60,
4 80,
5 70;
#sink #total 270
param S_demand :=
6 80,
7 100,
8 90;
# link capacity
param: ARCS: COST_ARCS CAP_ARCS:=
1,6	10	50
1,7	10	50
1,8	10	50
2,6	10	50
2,7	10	50
2,8	10	50
3,6	10	50
3,7	10	50
3,8	10	50
4,6	10	50
4,7	10	50
4,8	10	50
5,6	10	50
5,7	10	50
5,8	10	50
;

```

**model.mod**
``` model.mod

set TASKset;
set SERVERset;
set ARCS within {TASKset cross SERVERset};
param T_supply {TASKset} >=0;
param S_demand {SERVERset} >=0;
set ARCS_ED := {i in TASKset, j in SERVERset: (i,j) in ARCS};
param COST_ARCS {ARCS} >=0;
param CAP_ARCS {ARCS} >=0;
var T_assign {(i,j) in ARCS_ED} >=0, <= CAP_ARCS[i,j];
# objective function
minimize Total_Cost:
	sum {(i,j) in ARCS} COST_ARCS[i,j]*T_assign[i,j];
subject to S_balance{j in SERVERset}:
	sum {(i,j) in ARCS_ED} T_assign[i,j] = S_demand[j];
subject to T_balance{i in TASKset}:
	sum {(i,j) in ARCS_ED} T_assign[i,j] = T_supply[i];

```

**runscript.run**
``` runscript.run
solve;
display Total_Cost;
display T_assign;
for {(i,j) in ARCS} {	
	if T_assign[i,j]>0 then {
		printf "T_assign: t%d s%d: %d\n", i, j, T_assign[i,j];	
	}		
}
```
