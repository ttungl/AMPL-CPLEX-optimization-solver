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