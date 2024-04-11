CREATE EXTENSION pg_cron;

SELECT cron.schedule('partition maintenance', '*/5 * * * *', $$ call partman.run_maintenance_proc(); $$);

UPDATE cron.job SET database = 'demopg' WHERE jobname = 'partition maintenance';

CREATE EXTENSION IF NOT EXISTS aws_lambda CASCADE;

create or replace procedure send_cron_job_failures (p_lambda_arn varchar, p_sns_topic_arn varchar) 
language plpgsql
as $$
declare
	v_message text;
begin

	SELECT 'DB Name = '|| database ||', Job = ' || command || ' started at = ' || start_time || ', with runid = ' || runid || ' has failed !!!' into v_message
	  FROM cron.job_run_details
	 WHERE status='failed'
	   AND runid = (select max(runid) from cron.job_run_details where command like '%run_maintenance_proc%' and status!='running');
	   
	if v_message is not null
	then
		v_message='{"message": "'||v_message||'", "sns_topic_arn" : "'|| p_sns_topic_arn || '"}';
		SELECT payload into v_message from aws_lambda.invoke(aws_commons.create_lambda_function_arn(p_lambda_arn), v_message::json );
		RAISE NOTICE '%',v_message;
	end if;

end;
$$;
