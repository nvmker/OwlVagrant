create database owl_staging_wp;
grant all privileges on owl_staging_wp.* to owl@localhost identified by 'owl' with grant option;
grant all privileges on owl_staging_wp.* to owl@"%" identified by 'owl' with grant option;
