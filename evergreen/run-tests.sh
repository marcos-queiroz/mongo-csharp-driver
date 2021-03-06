#!/bin/bash

set -o xtrace   # Write all commands first to stderr
set -o errexit  # Exit the script with error if any of the commands fail

# Supported/used environment variables:
#       AUTH                    Set to enable authentication. Values are: "auth" / "noauth" (default)
#       SSL                     Set to enable SSL. Values are "ssl" / "nossl" (default)
#       MONGODB_URI             Set the suggested connection MONGODB_URI (including credentials and topology info)
#       TOPOLOGY                Allows you to modify variables and the MONGODB_URI based on test topology 
#                               Supported values: "server", "replica_set", "sharded_cluster"

AUTH=${AUTH:-noauth}
SSL=${SSL:-nossl}
MONGODB_URI=${MONGODB_URI:-}
TOPOLOGY=${TOPOLOGY:-server}

############################################
#            Main Program                  #
############################################

# Provision the correct connection string and set up SSL if needed
if [ "$TOPOLOGY" == "sharded_cluster" ]; then

     if [ "$AUTH" = "auth" ]; then
       export MONGODB_URI="mongodb://bob:pwd123@localhost:27017/?authSource=admin"
     else
       export MONGODB_URI="mongodb://localhost:27017"
     fi
fi

echo "Running $AUTH tests over $SSL for $TOPOLOGY and connecting to $MONGODB_URI"

if [ "$FRAMEWORK" == "netcore10" ]; then
  export TARGET="TestNetCore10"
else
  export TARGET="TestNet45"
fi

for var in TMP TEMP NUGET_PACKAGES NUGET_HTTP_CACHE_PATH APPDATA; do setx $var z:\\data\\tmp; export $var=z:\\data\\tmp; done
powershell.exe .\\build.ps1 -target ${TARGET}
