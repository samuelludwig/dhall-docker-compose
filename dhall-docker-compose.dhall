let List/map =
      https://prelude.dhall-lang.org/v11.1.0/List/map.dhall sha256:dd845ffb4568d40327f2a817eb42d1c6138b929ca758d50bc33112ef3c885680

let Map =
      https://raw.githubusercontent.com/dhall-lang/dhall-lang/master/Prelude/Map/Type

let StringOrNumber
    : Type
    = < String : Text | Number : Natural >

let ListOrDict
    : Type
    = < Dict : Map Text Text | List : List (Optional StringOrNumber) >

let EnvMap
    : Type
    = { mapKey : Text, mapValue : Text }

let FileList
    : Type
    = List Text

let createFileList
    : Text → List Text → FileList
    = λ(filesDir : Text) →
        List/map Text Text (λ(fileName : Text) → "${filesDir}/${fileName}")

let DependencyList
    : Type
    = List Text

let createEnvMap
    : Text → Text → EnvMap
    = λ(key : Text) → λ(value : Text) → { mapKey = key, mapValue = value }

let BuildClause
    : Type
    = { context : Text, dockerfile : Text }

let LoggingOptions
    : Type
    = { options : { max-size : Text, max-file : StringOrNumber } }

let createLogOpts
    : Text → StringOrNumber → LoggingOptions
    = λ(maxSize : Text) →
      λ(maxFile : StringOrNumber) →
        { options = { max-size = maxSize, max-file = maxFile } }

let PortsList = List StringOrNumber

let VolumesList = List Text

let Service =
      { Type =
          { container_name : Optional Text
          , image : Text
          , build : Optional BuildClause
          , restart : Optional Text
          , logging : Optional LoggingOptions
          , tty : Optional Bool
          , ports : Optional PortsList
          , volumes : Optional VolumesList
          , environment : Optional ListOrDict
          , env_file : Optional FileList
          , depends_on : Optional DependencyList
          , working_dir : Optional Text
          , networks : Optional (List Text)
          }
      , default =
        { container_name = None Text
        , build = None BuildClause
        , restart = Some "unless-stopped"
        , logging = Some (createLogOpts "5m" (StringOrNumber.String "15"))
        , tty = Some True
        , ports = None PortsList
        , volumes = None VolumesList
        , environment = None ListOrDict
        , env_file = None FileList
        , depends_on = None DependencyList
        , working_dir = None Text
        , networks = None (List Text)
        }
      }

let ServiceList
    : Type
    = Map Text Service.Type

let Network =
      { Type = { driver : Text, name : Text }, default.driver = "bridge" }

let NetworkMap
    : Type
    = { mapKey : Text, mapValue : Network.Type }

let NetworkList
    : Type
    = Map Text Network.Type

let createNetwork
    : Text → Network.Type
    = λ(networkName : Text) → Network::{ name = networkName }

let createNetworkMap
    : Text → Network.Type → NetworkMap
    = λ(networkName : Text) →
      λ(network : Network.Type) →
        { mapKey = networkName, mapValue = network }

let createNetworkMapFromName
    : Text → NetworkMap
    = λ(networkName : Text) →
        createNetworkMap networkName (createNetwork networkName)

let ComposeFile =
      { Type =
          { version : Text
          , services : Optional ServiceList
          , networks : Optional NetworkList
          }
      , default =
        { version = "3.5"
        , services = None ServiceList
        , networks = None NetworkList
        }
      }

in  { ComposeFile
    , StringOrNumber
    , ListOrDict
    , EnvMap
    , BuildClause
    , PortsList
    , VolumesList
    , Service
    , ServiceList
    , FileList
    , DependencyList
    , Network
    , NetworkList
    , LoggingOptions
    , createEnvMap
    , createFileList
    , createNetwork
    , createNetworkMap
    , createNetworkMapFromName
    }
