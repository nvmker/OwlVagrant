create database if not exists owl_staging_wp;
grant all privileges on owl_staging_wp.* to owl@localhost identified by 'owl' with grant option;
grant all privileges on owl_staging_wp.* to owl@"%" identified by 'owl' with grant option;

create database if not exists owl_staging_mediawiki;
grant all privileges on owl_staging_mediawiki.* to owl_mediawiki@localhost identified by 'secret' with grant option;
grant all privileges on owl_staging_mediawiki.* to owl_mediawiki@"%" identified by 'secret' with grant option;
