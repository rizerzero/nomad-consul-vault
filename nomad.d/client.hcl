client {
  enabled = true
  host_volume "qnap-nfs" {
    path = "/opt/NFS"
    read_only = false
  }
  server_join {
    retry_join = [ "192.168.90.21", "192.168.90.22" ]
    retry_max = 3
    retry_interval = "15s"
  }
  meta {
  }
}

plugin "docker" {
  config {
    allow_caps = [ "ALL" ]
    volumes {
      enabled = false
    }
  }
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}

