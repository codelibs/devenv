#!/bin/sh

/opt/opendj/setup \
      --cli \
      --baseDN dc=fess,dc=codelibs,dc=org \
      --sampleData 1 \
      --ldapPort 1389 \
      --adminConnectorPort 4444 \
      --rootUserDN cn=Directory\ Manager \
      --rootUserPassword password \
      --enableStartTLS \
      --ldapsPort 1636 \
      --generateSelfSignedCertificate \
      --hostName localhost.localdomain \
      --no-prompt \
      --noPropertiesFile \
      --acceptLicense
RET=$?
if [ $RET != 0 ] ; then
  exit $RET
fi
/opt/opendj/bin/ldapmodify \
      --hostname localhost \
      --port 1389 \
      --bindDN cn=Directory\ Manager \
      --bindPassword password \
      --defaultAdd \
      --filename /opt/setup/create-group.ldif
RET=$?
if [ $RET != 0 ] ; then
  exit $RET
fi
/opt/opendj/bin/ldapmodify \
      --hostname localhost \
      --port 1389 \
      --bindDN cn=Directory\ Manager \
      --bindPassword password \
      --defaultAdd \
      --filename /opt/setup/create-role.ldif
RET=$?
if [ $RET != 0 ] ; then
  exit $RET
fi
/opt/opendj/bin/ldapmodify \
      --hostname localhost \
      --port 1389 \
      --bindDN cn=Directory\ Manager \
      --bindPassword password \
      --defaultAdd \
      --filename /opt/setup/user-data.ldif
RET=$?
if [ $RET != 0 ] ; then
  exit $RET
fi

