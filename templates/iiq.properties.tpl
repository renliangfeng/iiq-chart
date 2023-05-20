{{- define "iiq.properties" -}}
##### iiq.properties #####

######################################################
### Properties that vary by environment
######################################################
dataSource.username={{.Values.database.username}}
dataSource.password={{.Values.database.password}}

dataSource.url={{.Values.database.url}}?useSSL=false&useServerPrepStmts=true&tinyInt1iShift=true&useLegacyDatetimeCode=false&serverTimezone=UTC
dataSource.driverClassName=com.mysql.cj.jdbc.Driver
sessionFactory.hibernateProperties.hibernate.dialect=sailpoint.persistence.MySQL5InnoDBDialect

######################################################
### Properties that are constant across environments/versions
######################################################

jndiDataSource.jndiName=java:comp/env/jdbc/testDataSource
configuredDataSource.targetBeanName=dataSource

#pool size setup
dataSource.initialSize=10
dataSource.minIdle=10
dataSource.maxIdle=20
dataSource.maxTotal=250

#pool size grooming
#15 minutes = 900000 ms
dataSource.minEvictableIdleTimeMillis=900000
#we use this so we respect minIdle; setting them both to 15 min here means
#we have about 15 min (min evict times) + 10 min (evict run timing)...about 25 min to idle connections to sit
dataSource.softMinEvictableIdleTimeMillis=900000
#10 minutes = 600000 ms
dataSource.timeBetweenEvictionRunsMillis=600000

#connection testing
#20 seconds = 20000 ms
dataSource.maxWaitMillis=20000
dataSource.testOnBorrow=true
dataSource.testOnReturn=true
dataSource.validationQuery=SELECT 1
#20 seconds
dataSource.validationQueryTimeout=20

bsfManagerFactory.maxManagerReuse=100
bsfManagerPool.maxTotal=30
bsfManagerPool.minEvictableIdleTimeMillis=900000
bsfManagerPool.timeBetweenEvictionRunsMillis=600000

plugins.enabled=true
plugins.angularSnippetEnabled=true
pluginsDataSource.username={{.Values.pluginsDatabase.username}}
pluginsDataSource.password={{.Values.pluginsDatabase.password}}
pluginsDataSource.url={{.Values.pluginsDatabase.url}}?useSSL=false&useServerPrepStmts=true&tinyInt1isBit=true&useUnicode=true&characterEncoding=utf8&useJDBCCompliantTimezoneShift=true&useLegacyDatetimeCode=false&serverTimezone=UTC
pluginsDataSource.driverClassName=com.mysql.cj.jdbc.Driver

{{- if .Values.keystore.enabled }}
keyStore.file={{ .Values.keystore.mountPath }}/iiq.dat
keyStore.passwordFile={{ .Values.keystore.mountPath }}/iiq.cfg
{{- end }}
{{- end }}
