let Compose = ./dhall-docker-compose.dhall

let createNet = Compose.createNetworkMapFromName

let toFileList = Compose.createFileList

let networkList = [ createNet "example-network" ]

let envFilesDir = "./config"

let exampleManagerVolumes =
      [ "./example:/var/www/public"
      , "./example/local.ini:/usr/local/etc/php/conf.d/local.ini"
      ]

let exampleManagerService =
      Compose.Service::{
      , image = "example-manager"
      , container_name = Some "example-manager"
      , build = Some { context = "./example", dockerfile = "Dockerfile" }
      , volumes = Some exampleManagerVolumes
      , networks = Some [ "example-network" ]
      }

let exampleWebserverEnvFiles =
      [ "message-server.env"
      , "manager-database.env"
      , "example-database.env"
      , "curl.env"
      ]

let exampleWebserverEnvFileList =
      toFileList envFilesDir exampleWebserverEnvFiles

let exampleWebserverVolumes =
      [ "./example:/var/www/public/"
      , "./webserver/templates:/etc/nginx/templates"
      , "./webserver/conf.d:/etc/nginx/conf.d"
      ]

let exampleWebserverService =
      Compose.Service::{
      , image = "nginx:alpine"
      , container_name = Some "example-webserver"
      , ports = Some
        [ Compose.StringOrNumber.String "80:80"
        , Compose.StringOrNumber.String "443:443"
        ]
      , env_file = Some exampleWebserverEnvFileList
      , volumes = Some exampleWebserverVolumes
      , networks = Some [ "example-network" ]
      , working_dir = Some "/var/www/public"
      , depends_on = Some [ "example" ]
      }

let databaseSynchronizerService =
      Compose.Service::{
      , image = "db-syncer"
      , container_name = Some "example-db-syncer"
      , build = Some
        { context = "./db-sync-service"
        , dockerfile = "Dockerfile"
        }
      , networks = Some [ "example-network" ]
      , env_file = Some (toFileList envFilesDir [ "database-synchronizer.env" ])
      , working_dir = Some "/app"
      }

let services
    : Compose.ServiceList
    = [ { mapKey = "webserver", mapValue = exampleWebserverService }
      , { mapKey = "example", mapValue = exampleManagerService }
      , { mapKey = "db-syncer", mapValue = databaseSynchronizerService }
      ]

let composeFile =
      Compose.ComposeFile::{
      , services = Some services
      , networks = Some networkList
      }

in  composeFile
