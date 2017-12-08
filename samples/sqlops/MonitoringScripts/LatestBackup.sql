/* Latest backup deatils */
select   top 1 start_time, end_time, progress AS progress_percent
from     sys.pdw_loader_backup_runs 
order by run_id desc