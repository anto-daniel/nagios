CREATE DATABASE nconf CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER 'nconf' identified by 'nconf';
GRANT ALL ON nconf.* TO 'nconf'@'localhost' IDENTIFIED BY 'nconf';
