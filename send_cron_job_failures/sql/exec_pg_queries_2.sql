CREATE SCHEMA partman;
CREATE EXTENSION pg_partman WITH SCHEMA partman;

CREATE SCHEMA data_mart;

CREATE TABLE data_mart.organization( 
	org_id 			SERIAL,
	org_name 		TEXT,
	CONSTRAINT pk_organization PRIMARY KEY (org_id)
);

/* In below example, created_at column is used as partition key for the table and is also included as part of the primary key, to enforce uniqueness across partitions */

CREATE TABLE data_mart.events_daily(
    event_id        INT,
    operation       VARCHAR(1),
    value           FLOAT(24),
    parent_event_id INT,
    event_type      VARCHAR(25),
    org_id          INT,
    created_at      TIMESTAMPTZ,
    CONSTRAINT pk_data_mart_events_daily PRIMARY KEY (event_id, created_at),
    CONSTRAINT ck_valid_operation CHECK (operation = 'C' OR operation = 'D'),
    CONSTRAINT fk_orga_membership_events_daily FOREIGN KEY(org_id)
    REFERENCES data_mart.organization (org_id),
    CONSTRAINT fk_parent_event_id_events_daily FOREIGN KEY(parent_event_id, created_at)
    REFERENCES data_mart.events_daily (event_id,created_at)
) PARTITION BY RANGE (created_at);

CREATE INDEX idx_org_id_events_daily     ON data_mart.events_daily(org_id);
CREATE INDEX idx_event_type_events_daily ON data_mart.events_daily(event_type);

CREATE TABLE data_mart.events_monthly(
	event_id        INT,
	value           FLOAT(24),
	parent_event_id INT,
	org_id          INT,
	created_at      TIMESTAMPTZ,
	CONSTRAINT pk_data_mart_events_monthly PRIMARY KEY (event_id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE data_mart.events_quarterly(
	event_id        INT,
	value           FLOAT(24),
	parent_event_id INT,
	org_id          INT,
	created_at      TIMESTAMPTZ,
	CONSTRAINT pk_data_mart_events_quarterly PRIMARY KEY (event_id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE data_mart.events_yearly(
	event_id        INT,
	value           FLOAT(24),
	parent_event_id INT,
	org_id          INT,
	created_at      TIMESTAMPTZ,
	CONSTRAINT pk_data_mart_events_yearly PRIMARY KEY (event_id, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE data_mart.events_range(
	event_id        INT,
	value           FLOAT(24),
	parent_event_id INT,
	org_id          INT,
	created_at      TIMESTAMPTZ,
	CONSTRAINT pk_data_mart_events_range PRIMARY KEY (event_id)
) PARTITION BY RANGE (event_id);

CREATE TABLE data_mart.events_daily_hourly(
	event_id        INT,
	value           FLOAT(24),
	parent_event_id INT,
	org_id          INT,
	event_date		TIMESTAMPTZ,
	created_at      TIMESTAMPTZ,
	CONSTRAINT pk_data_mart_events_daily_hourly PRIMARY KEY (event_date, created_at)
) PARTITION BY RANGE (created_at);

CREATE TABLE data_mart.events_daily_range(
	event_id        INT,
	value           FLOAT(24),
	parent_event_id INT,
	org_id          INT,
	created_at      TIMESTAMPTZ,
	CONSTRAINT pk_data_mart_events_daily_range PRIMARY KEY (event_id, created_at)
) PARTITION BY RANGE (created_at);


SELECT partman.create_parent( p_parent_table => 'data_mart.events_daily',
p_control => 'created_at',
p_type => 'range',
p_interval=> '1 day',
p_start_partition := '2022-04-01 00:00:00'::text,
p_premake => 35);

SELECT partman.create_parent( p_parent_table => 'data_mart.events_monthly',
p_control => 'created_at',
p_type => 'range',
p_interval=> '1 month',
p_start_partition => '2022-04-01 00:00:00'::text,
p_premake => 13);

SELECT partman.create_parent( p_parent_table => 'data_mart.events_quarterly',
p_control => 'created_at',
p_type => 'range',
p_interval=> '3 months',
p_start_partition => '2022-04-01 00:00:00'::text,
p_premake => 5);

SELECT partman.create_parent( p_parent_table => 'data_mart.events_yearly',
p_control => 'created_at',
p_type => 'range',
p_interval=> '1 year',
p_start_partition => '2022-04-01 00:00:00'::text,
p_premake => 2);

SELECT partman.create_parent( p_parent_table => 'data_mart.events_range',
p_control => 'event_id',
p_type => 'range',
p_interval=> '10000',
p_start_partition => '1',
p_premake => 3);

SELECT partman.create_parent( p_parent_table => 'data_mart.events_daily_hourly',
p_control => 'created_at',
p_type => 'range',
p_interval=> '1 day',
p_start_partition => '2022-04-01 00:00:00'::text,
p_premake => 1);

SELECT partman.create_sub_parent( p_top_parent => 'data_mart.events_daily_hourly',
p_control => 'event_date',
p_type => 'range',
p_interval=> '1 hour',
p_start_partition => '2022-04-01 00:00:00'::text,
p_declarative_check => 'yes',
p_premake => 24);

SELECT partman.create_parent( p_parent_table => 'data_mart.events_daily_range',
p_control => 'created_at',
p_type => 'range',
p_interval=> '1 day',
p_start_partition => '2022-04-01 00:00:00'::text,
p_premake => 1);

SELECT partman.create_sub_parent( p_top_parent => 'data_mart.events_daily_range',
p_control => 'event_id',
p_type => 'range',
p_interval=> '10000',
p_start_partition => '1',
p_declarative_check => 'yes',
p_premake => 3);

update partman.part_config
set infinite_time_partitions=true
where parent_table like 'data_mart.events_%';
