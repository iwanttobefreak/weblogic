import ConfigParser
import getopt
import os

def create_cluster(v_name,v_listenaddress,v_balanceo):
  cd('/')
  create(v_name, 'Cluster')
  cd('/Clusters/' + v_name)
  cmo.setClusterMessagingMode('unicast')
  cmo.setWeblogicPluginEnabled(true)
  cmo.setClusterAddress(v_listenaddress)
  cmo.setDefaultLoadAlgorithm(v_balanceo)

def create_nodemanager(v_name,v_ip):
  cd('/')
  cmo.createUnixMachine(v_name)

  cd('/Machines/' + v_name + '/NodeManager/' + v_name)
  cmo.setNMType('Plain')
  cmo.setListenAddress(v_ip)

def create_managed(v_name,v_nodemanager,v_ip,v_port,v_cluster):
  cd('/')
  cmo.createServer(v_name)
  cd('/Servers/' + v_name)
  cmo.setListenAddress(v_ip)
  cmo.setListenPort(int(v_port))
  cmo.setMachine(getMBean('/Machines/' + v_nodemanager))
  cmo.setWeblogicPluginEnabled(true)
  cmo.setCluster(getMBean('/Clusters/' + v_cluster))
  cd('/Servers/' + v_name + '/SSL/' + v_name)
  cmo.setHostnameVerificationIgnored(true)
  cd('/Servers/' + v_name + '/ServerStart/' + v_name)

def create_datasource(v_name,v_jndi,v_url,v_user,v_globaltransaction,v_ons,v_target):
  cd('/')
  cmo.createJDBCSystemResource(v_name)
  cd('/JDBCSystemResources/' + v_name + '/JDBCResource/' + v_name)
  cmo.setName(v_name)
  cd('/JDBCSystemResources/' + v_name + '/JDBCResource/' + v_name + '/JDBCDataSourceParams/' + v_name)
  set('JNDINames',jarray.array([String(v_jndi) ], String))
  cmo.setGlobalTransactionsProtocol(v_globaltransaction)
  cd('/JDBCSystemResources/' + v_name + '/JDBCResource/' + v_name + '/JDBCDriverParams/' + v_name)
  cmo.setUrl(v_url)
  cmo.setDriverName('oracle.jdbc.OracleDriver')
  cd('/JDBCSystemResources/' + v_name + '/JDBCResource/' + v_name + '/JDBCDriverParams/' + v_name + '/Properties/' + v_name)
  cmo.createProperty('user')
  cd('/JDBCSystemResources/' + v_name + '/JDBCResource/' + v_name + '/JDBCDriverParams/' + v_name + '/Properties/' + v_name + '/Properties/user')
  cmo.setValue(v_user)

  cd('/JDBCSystemResources/'+v_name+'/JDBCResource/'+v_name+'/JDBCOracleParams/' + v_name)

#  cmo.setFanEnabled(true)
#  cmo.setOnsWalletFile('system')
  cmo.setOnsNodeList(v_ons)

  cd('/SystemResources/' + v_name)
  set('Targets',jarray.array([ObjectName('com.bea:Name=' + v_target + ',Type=Cluster')], ObjectName))
  cd('/JDBCSystemResources/' + v_name + '/JDBCResource/' + v_name + '/JDBCConnectionPoolParams/' + v_name)
  cmo.setTestConnectionsOnReserve(true)
  cmo.setWrapTypes(false)
  cmo.setMaxCapacity(120)

def create_timer(v_target,v_datasource,v_table):
  cd('/Clusters/' + v_target)
  cmo.setJobSchedulerTableName(v_table)
  cmo.setDataSourceForJobScheduler(getMBean('/SystemResources/' + v_datasource))

def create_timerleasing(v_target,v_datasource,v_migration_basis,v_migrationtable):
  cd('/')
  v_machines=cmo.getMachines()
  cd('/Clusters/' + v_target)
  cmo.setMigrationBasis(v_migration_basis)
  cmo.setAutoMigrationTableName(v_migrationtable)
  set('CandidateMachinesForMigratableServers',v_machines)
  cmo.setDataSourceForAutomaticMigration(getMBean('/SystemResources/' + v_datasource))

def create_filestore_migratable(v_filestore,v_directory,v_target): 
  cd('/')
  cmo.createFileStore(v_filestore)
  cd('/FileStores/' + v_filestore)
  cmo.setDirectory(v_directory)
  set('Targets',jarray.array([ObjectName('com.bea:Name=' + v_target + ' (migratable),Type=MigratableTarget')], ObjectName))

def create_jmsserver_migratable (v_name,v_persistent_store,v_target):
  cd('/')
  cmo.createJMSServer(v_name)
  cd('/Deployments/' + v_name)
  cmo.setPersistentStore(getMBean('/FileStores/' + v_persistent_store))
  set('Targets',jarray.array([ObjectName('com.bea:Name=' + v_target + ' (migratable),Type=MigratableTarget')], ObjectName))




v_fichero=sys.argv[1]
connect('weblogic', 'weblogic01','t3://localhost:7001')
edit()
startEdit()

config = ConfigParser.ConfigParser()
config.read(v_fichero)


##################
#  nodemanager   #
##################
i=1
e='inicio'
while e != 'fin':
  try:
    v_seccion='nodemanager'
    v_name = config.get(v_seccion + '_' + str(i) , 'name')
    v_ip = config.get(v_seccion + '_' + str(i) , 'ip')
    print "Create nodemanager: " + v_name + " ip: " + v_ip
    create_nodemanager(v_name,v_ip)
    i=i+1
  except ConfigParser.NoSectionError:
    e='fin'
    pass


##################
#     Cluster    #
##################

i=1
e='inicio'
while e != 'fin':
  try:
    v_seccion='cluster'
    v_name = config.get(v_seccion + '_' + str(i) , 'name')
    v_listenaddress=config.get(v_seccion + '_' + str(i) , 'listen_address')
    v_balanceo=config.get(v_seccion + '_' + str(i) , 'balanceo')

    print "Create Cluster: " + v_name

    create_cluster(v_name,v_listenaddress,v_balanceo)

    i=i+1
  except ConfigParser.NoSectionError:
    e='fin'
    pass

##################
#    manageds    #
##################
i=1
e='inicio'
while e != 'fin':
  try:
    v_seccion='managed'

    v_name       = config.get(v_seccion + '_' + str(i) , 'name')
    v_nodemanager= config.get(v_seccion + '_' + str(i) , 'nodemanager')
    v_ip         = config.get(v_seccion + '_' + str(i) , 'ip')
    v_port       = config.get(v_seccion + '_' + str(i) , 'port')
    v_cluster    = config.get(v_seccion + '_' + str(i) , 'target')

    create_managed(v_name,v_nodemanager,v_ip,v_port,v_cluster)

    i=i+1
  except ConfigParser.NoSectionError:
    e='fin'
    pass


##################
#   datasource   #
##################
i=1
e='inicio'
while e != 'fin':
  try:
    v_seccion='datasource'

    v_name   = config.get(v_seccion + '_' + str(i) , 'name')
    v_jndi   = config.get(v_seccion + '_' + str(i) , 'jndi')
    v_url    = config.get(v_seccion + '_' + str(i) , 'url')
    v_user   = config.get(v_seccion + '_' + str(i) , 'user')
    v_globaltransaction = config.get(v_seccion + '_' + str(i) , 'globaltransaction')
    v_ons   = config.get(v_seccion + '_' + str(i) , 'ons')
    v_target = config.get(v_seccion + '_' + str(i) , 'target')

    create_datasource(v_name,v_jndi,v_url,v_user,v_globaltransaction,v_ons,v_target)

    i=i+1
  except ConfigParser.NoSectionError:
    e='fin'
    pass


##################
#     timer      #
##################
i=1
e='inicio'
while e != 'fin':
  try:
    v_seccion='timer'

    v_target = config.get(v_seccion + '_' + str(i) , 'target')
    v_datasource = config.get(v_seccion + '_' + str(i) , 'datasource')
    v_table = config.get(v_seccion + '_' + str(i) , 'table')
    
    create_timer(v_target,v_datasource,v_table)

    i=i+1
  except ConfigParser.NoSectionError:
    e='fin'
    pass

##################
# timer_leasing  #
##################
i=1
e='inicio'
while e != 'fin':
  try:
    v_seccion='timer_leasing'

    v_target = config.get(v_seccion + '_' + str(i) , 'target')
    v_datasource = config.get(v_seccion + '_' + str(i) , 'datasource')
    v_migration_basis = config.get(v_seccion + '_' + str(i) , 'migration_basis')
    v_migration_table = config.get(v_seccion + '_' + str(i) , 'migration_table')

    create_timerleasing(v_target,v_datasource,v_migration_basis,v_migration_table)

    i=i+1
  except ConfigParser.NoSectionError:
    e='fin'
    pass

###############################
# persistent store migratable #
###############################
i=1
e='inicio'
while e != 'fin':
  try:
    v_seccion='persistent_store_migratable'

    v_filestore = config.get(v_seccion + '_' + str(i) , 'filestore')
    v_directory = config.get(v_seccion + '_' + str(i) , 'directory')
    v_target = config.get(v_seccion + '_' + str(i) , 'target')

    create_filestore_migratable(v_filestore,v_directory,v_target)

    i=i+1
  except ConfigParser.NoSectionError:
    e='fin'
    pass

################################
#  create_jmsserver_migratable #
################################
i=1
e='inicio'
while e != 'fin':
  try:
    v_seccion='jms_server_migratable'

    v_name = config.get(v_seccion + '_' + str(i) , 'name')
    v_persistent_store = config.get(v_seccion + '_' + str(i) , 'persistent_store')
    v_target = config.get(v_seccion + '_' + str(i) , 'target')

    create_jmsserver_migratable (v_name,v_persistent_store,v_target)

    i=i+1
  except ConfigParser.NoSectionError:
    e='fin'
    pass



activate()
exit()
