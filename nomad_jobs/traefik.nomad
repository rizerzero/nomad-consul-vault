//
// Jonathan Gonzalez
// j@0x30.io
// https://github.com/EA1HET
// Nomad v1.0.0 
// Plan date: 2020-12-15
// Job version: 1.0
//
// A Traefik load balancer and reverse proxy server


job "traefik" {
  // This jobs will instantiate a Traefik load balancer and reverse proxy

  region = "global"
  datacenters = ["LAB"]
  type = "service"

  group "proxy" {
    // Number of executions per task that will grouped into the same Nomad host 
    count = 3

    task "traefik" {
       driver = "docker"
       // This is a Docker task using the local Docker daemon 
      
      config {
        // This is the equivalent to a docker run command line
        image = "traefik:2.3.5"
        network_mode = "host"
        port_map { http    = 80   } 
        port_map { https   = 443  } 
        port_map { api     = 8081 } 
        port_map { metrics = 8082 } 

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
          "/opt/NFS/traefik/acme.json:/etc/traefik/acme.json",
        ]
      } 

      template {
        data = <<EOF

[entryPoints]
  [entryPoints.http]
  address = ":80"
  [entryPoints.https]
  address = ":443"
  [entryPoints.api]
  address = ":8081"
  [entryPoints.metrics]
  address = ":8082"

[ping]
  entryPoint = "http"

[api]
  dashboard = true
  insecure = true
  debug = true

# Enable Consul Catalog configuration backend.
[providers.consulCatalog]
  prefix = "traefik"
  exposedByDefault = false
  [providers.consulCatalog.endpoint]
    address = "http://127.0.0.1:8500"
    scheme = "http"

EOF
        destination = "local/traefik.toml"
      }

      service {
        name = "traefik"
        check {
          name     = "alive"
          type     = "tcp"
          port     = "http"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        // Hardware limits in this cluster
        cpu = 1000
        memory = 1024
        network {
          mbits = 100
          port "http"    { static = 80 }
          port "https"   { static = 443 }
          port "api"     { static = 8081 }
          port "metrics" { static = 8082 }
        }
      }

      restart {
        // The number of attempts to run the job within the specified interval
        attempts = 10
        interval = "5m"
        delay = "25s"
        mode = "delay"
      } 

      logs {
        max_files = 5
        max_file_size = 15
      } 

    } // EndTask
  } // EndGroup
} // EndJob
