variable "name" {
  type        = string
  description = "Name of the helm chart"
  default     = "wart"
}

variable "chart" {
  type        = string
  description = "Directory of our helm chart"
  default     = "/root/wart"
}

variable "kubeConfig" {
    type = string
    description = "the path of kubectl config file"
    default = "/root/.kube/config"
}

variable "wordpress" {
    type = object({
        replica = int
        name = string
        containerName = string
        image = string
        internalPort = int
        service = object({
            type = string
            externalPort = int
            name = string
        })
        ingress = object({
            name = string
            host = string
            path = string
        })
        issuer = object({
            email = string
        })
    })

    default = {
        replica = 1
        name = "wp-app"
        containerName = "wordpress"
        image = "wordpress:latest"
        internalPort = 80
        service = {
            type = "ClusterIP"
            externalPort = 80
            name = "wp-svc"
        }
        ingress = {
            name = "wp-ingress"
            host = "pooria-shahi-nl-rg3.maxtld.dev"
            path = "https://pooria-shahi-nl-rg3.maxtld.dev/wordpress"
        }
        issuer = {
            email = "PooriaPro@gmail.com"
        }
    }
}

variable "mysql" {
    replica = int
    name = string
    containerName = string
    image = string
    internalPort = int
    service = object({
        type = string
        externalPort = int
        name = string
    })
    pv = object({
        name = string
        path = string
    })
    pvc = object({
        name = string
        storageClass = string
        size = int
    })
    config = object({
        name = string
        username = object({
            key = string
            value = string
        })
        database = object({
            key = string
            value = string
        })
    })
    secret = object({
        name = string
        rootPassword = object({
            key = string
            value = string
        })
        password = object({
            key = string
            value = string
        })
    })

    default = {
        replica = 1
        name = "mysql-app"
        containerName = "mysql"
        image = "mysql:latest"
        internalPort = 3306
        service = {
            type = "ClusterIP"
            externalPort = 3306
            name = "mysql-svc"
        }
        pv = {
            name = "mysql-pv"
            path = "/mnt/data"
        }
        pvc = {
            name = "mysql-pvc"
            storageClass = "manual"
            size = 5
        }
        config = {
            name = "mysql-configmap"
        }
        username = {
            key = "username"
            value = "wp"
        }
        database = {
            key = "database"
            value = "wp"
        }
        secret = {
            name = "mysql-secret"
            rootPassword = {
                key = "rootPassword"
                value = "hadsgdauhoasidjmasldasdad"
            }
            password = {
                key = "password"
                value = "hadsgdauhoasidj"
            }
        }
    }
}

variable "pma" {
    name = string
    internalPort = int
    service = object({
        name = string
        externalPort = int
    })
    ingress = object({
        name = string
    })

    default = {
        name = "pma-app"
        internalPort = 80
        service = {
            name = "pma-svc"
            externalPort = 80
        }
        ingress = {
            name = "pma-ingress"
        }
    }
}