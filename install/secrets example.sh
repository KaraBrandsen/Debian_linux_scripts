ZT_TOKEN=""                                     #Your Zerotier API Token - Get this from https://my.zerotier.com/account -> "new token"
NWID=""                                         #Your Zerotier Network ID - Get this from https://my.zerotier.com/
WIN_USER=""                                     #Username used to access the windows shares
WIN_PASS=""                                     #Password used to access the windows shares
WIN_HOST=192.168.0.2                            #IP address of the windows/samba host
WIN_SHARES=( D nas )                            #An array of the names of the shared folders. Eg //192.168.0.2/D is D 
SAMBA_USER=""                                   #Username to be used when configuring samba shares
SAMBA_PASS=""                                   #Password to be used when configuring samba shares
KUMA_USER="admin"
KUMA_PASS=""
RUSTDESK_PASS=""
RUSTDESK_CFG=""


#This is a list of news severs used to configure SABNZBd. You can specify more than one.
SERVERS='[{
"SERVER_HOST":"news.server.com",		
"SERVER_PORT":563,					
"SERVER_USERNAME":"",		        				
"SERVER_PASSWORD":"",            				
"SERVER_CONNECTIONS":20,					
"SERVER_SSL":1	
}]'

#This is a list of indexers used to configure Sonarr/Radarr. You can specify more than one. Only Newznab support for now
INDEXERS='[{						
"INDEXER_NAME":"NZBSA",	
"INDEXER_URL":"https://nzbsa.com/",			                
"INDEXER_API_PATH":"/api",									
"INDEXER_APIKEY":""	                               
}]'