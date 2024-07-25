#!/bin/bash

sed -e "s!_DVWA_DB_SERVER_!${DVWA_DB_SERVER}!" \
    -e "s!_DVWA_DBNAME_!${DVWA_DBNAME}!" \
    -e "s!_DVWA_DBUSERNAME_!${DVWA_DBUSERNAME}!" \
    -e "s!_DVWA_DBPASSWORD_!${DVWA_DBPASSWORD}!" \
    -e "s!_DVWA_DBPORT_!${DVWA_DBPORT}!" \
    -e "s!_DVWA_WEB_CONTEXTROOT_!${DVWA_WEB_CONTEXTROOT}!" \
    -i config/config.inc.php

sed -e "s/_DVWA_ADMIN_PASSWORD_/${DVWA_ADMIN_PASSWORD}/" \
    -i dvwa/includes/DBMS/MySQL.php

exec apache2-foreground
