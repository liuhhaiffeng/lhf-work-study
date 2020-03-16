create view vux_dist_placement_node as 
    (select placementid, shardid, shardstate, shardlength, A.groupid, nodeid, nodename, nodeport, noderack, hasmetadata, isactive, noderole, nodecluster from ux_dist_placement A inner join ux_dist_node B on A.groupid = B.groupid);

create view vux_uxbench_count as
    select 'uxbench_accounts', count(*) from uxbench_accounts union select 'uxbench_branches', count(*) from uxbench_branches union select 'uxbench_history', count(*) from uxbench_history union select 'uxbench_tellers', count(*) from uxbench_tellers ;
