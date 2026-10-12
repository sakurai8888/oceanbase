This is a repository for Oceanbase

/*+monitor*/


select last_trace_id() from duel;

select top_id,thread,svr_ip,op,output_rows,rescan,db_time/1000
db_time_ms,(close_time-open_time)open_dt,(last_row_eof_time-first_row_time)
row_dt,op
en_time,close_time,first_row_time,last_row_eof_timefrom(selectplan_line_id
op_id,process_namethread,svr_ip,db_time,concat(lpad('',plan_depth,'
'),plan_operation)op,output_ro
ws,startsrescan,first_refresh_timeopen_time,last_refresh_time
close_time,first_change_timefirst_row_time,last_change_timelast_row_eof_time
fromsys.gv$sql_plan_monitor where trace_id='YB420AE0010E-0006385D585E61A4-0-0'orderby
plan_line_id,process_name)a;



