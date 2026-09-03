extension radius

param environment string

@secure()
param rabbitPassword string

@secure()
param rabbitUsername string

@secure()
param registryPassword string

@secure()
param registryUsername string

resource aksStoreDemoApp 'Radius.Core/applications@2025-08-01-preview' = {
  name: 'aks-store-demo'
  properties: {
    environment: environment
  }
}

resource mongoDb 'Radius.Data/mongoDatabases@2025-08-01-preview' = {
  name: 'mongo'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'aks-store-all-in-one.yaml#L2'
    database: 'orderdb'
  }
}

resource rabbitMq 'Radius.Messaging/rabbitMQ@2025-08-01-preview' = {
  name: 'rabbitmq'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'aks-store-all-in-one.yaml#L76'
    password: rabbitPassword
    queue: 'orders'
    username: rabbitUsername
  }
}

resource rabbitCredentials 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'rabbitmq-client-credentials'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'aks-store-all-in-one.yaml#L69'
    data: {
      ORDER_QUEUE_PASSWORD: {
        value: rabbitPassword
      }
      ORDER_QUEUE_USERNAME: {
        value: rabbitUsername
      }
    }
  }
}

resource registryCreds 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'radius-ghcr-registry-creds'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: '.radius/app.bicep#L63'
    data: {
      password: {
        value: registryPassword
      }
      username: {
        value: registryUsername
      }
    }
  }
}

resource makelineServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'makeline-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/makeline-service/Dockerfile#L1'
    tag: 'sha-3f93ad153fbb'
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nellshamrell/aks-store-demo.git//src/makeline-service?ref=3f93ad153fbb2b2001e07a71f97d0d897f290a62'
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource orderServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'order-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/order-service/Dockerfile#L1'
    tag: 'sha-3f93ad153fbb'
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nellshamrell/aks-store-demo.git//src/order-service?ref=3f93ad153fbb2b2001e07a71f97d0d897f290a62'
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource productServiceImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'product-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/product-service/Dockerfile#L1'
    tag: 'sha-3f93ad153fbb'
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nellshamrell/aks-store-demo.git//src/product-service?ref=3f93ad153fbb2b2001e07a71f97d0d897f290a62'
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource storeAdminImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'store-admin-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/store-admin/Dockerfile#L1'
    tag: 'sha-3f93ad153fbb'
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nellshamrell/aks-store-demo.git//src/store-admin?ref=3f93ad153fbb2b2001e07a71f97d0d897f290a62'
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource storeFrontImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'store-front-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/store-front/Dockerfile#L1'
    tag: 'sha-3f93ad153fbb'
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nellshamrell/aks-store-demo.git//src/store-front?ref=3f93ad153fbb2b2001e07a71f97d0d897f290a62'
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource virtualCustomerImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'virtual-customer-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/virtual-customer/Dockerfile#L1'
    tag: 'sha-3f93ad153fbb'
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nellshamrell/aks-store-demo.git//src/virtual-customer?ref=3f93ad153fbb2b2001e07a71f97d0d897f290a62'
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource virtualWorkerImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'virtual-worker-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/virtual-worker/Dockerfile#L1'
    tag: 'sha-3f93ad153fbb'
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nellshamrell/aks-store-demo.git//src/virtual-worker?ref=3f93ad153fbb2b2001e07a71f97d0d897f290a62'
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource makelineServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'makeline'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/makeline-service/main.go#L21'
    containers: {
      service: {
        image: makelineServiceImage.properties.imageReference
        env: {
          ORDER_DB_COLLECTION_NAME: {
            value: 'orders'
          }
          ORDER_DB_NAME: {
            value: 'orderdb'
          }
          ORDER_DB_URI: {
            valueFrom: {
              secretKeyRef: {
                secretName: mongoDb.properties.secrets.name
                key: 'connectionString'
              }
            }
          }
          ORDER_QUEUE_NAME: {
            value: 'orders'
          }
          ORDER_QUEUE_PASSWORD: {
            valueFrom: {
              secretKeyRef: {
                secretName: rabbitCredentials.name
                key: 'ORDER_QUEUE_PASSWORD'
              }
            }
          }
          ORDER_QUEUE_URI: {
            value: 'amqp://${rabbitMq.properties.host}:${rabbitMq.properties.port}'
          }
          ORDER_QUEUE_USERNAME: {
            valueFrom: {
              secretKeyRef: {
                secretName: rabbitCredentials.name
                key: 'ORDER_QUEUE_USERNAME'
              }
            }
          }
        }
        ports: {
          web: {
            containerPort: 3001
          }
        }
      }
    }
    connections: {
      mongodb: {
        disableDefaultEnvVars: true
        source: mongoDb.id
      }
      rabbitmq: {
        disableDefaultEnvVars: true
        source: rabbitMq.id
      }
    }
  }
}

resource orderServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'order'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/order-service/app.js#L1'
    containers: {
      service: {
        image: orderServiceImage.properties.imageReference
        env: {
          FASTIFY_ADDRESS: {
            value: '0.0.0.0'
          }
          ORDER_QUEUE_HOSTNAME: {
            value: rabbitMq.properties.host
          }
          ORDER_QUEUE_NAME: {
            value: 'orders'
          }
          ORDER_QUEUE_PASSWORD: {
            valueFrom: {
              secretKeyRef: {
                secretName: rabbitCredentials.name
                key: 'ORDER_QUEUE_PASSWORD'
              }
            }
          }
          ORDER_QUEUE_PORT: {
            value: '${rabbitMq.properties.port}'
          }
          ORDER_QUEUE_USERNAME: {
            valueFrom: {
              secretKeyRef: {
                secretName: rabbitCredentials.name
                key: 'ORDER_QUEUE_USERNAME'
              }
            }
          }
        }
        ports: {
          web: {
            containerPort: 3000
          }
        }
      }
    }
    connections: {
      rabbitmq: {
        disableDefaultEnvVars: true
        source: rabbitMq.id
      }
    }
  }
}

resource productServiceContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'product'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/product-service/src/main.rs#L4'
    containers: {
      service: {
        image: productServiceImage.properties.imageReference
        ports: {
          web: {
            containerPort: 3002
          }
        }
      }
    }
  }
}

resource storeAdminContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'store-admin'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/store-admin/nginx.conf#L1'
    containers: {
      storeAdmin: {
        image: storeAdminImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8081
          }
        }
      }
    }
    connections: {
      makeline: {
        disableDefaultEnvVars: true
        source: makelineServiceContainer.id
      }
      order: {
        disableDefaultEnvVars: true
        source: orderServiceContainer.id
      }
      product: {
        disableDefaultEnvVars: true
        source: productServiceContainer.id
      }
    }
  }
}

resource storeFrontContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'store-front'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/store-front/nginx.conf#L1'
    containers: {
      storeFront: {
        image: storeFrontImage.properties.imageReference
        ports: {
          web: {
            containerPort: 8080
          }
        }
      }
    }
    connections: {
      order: {
        disableDefaultEnvVars: true
        source: orderServiceContainer.id
      }
      product: {
        disableDefaultEnvVars: true
        source: productServiceContainer.id
      }
    }
  }
}

resource virtualCustomerContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'virtual-customer'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/virtual-customer/src/main.rs#L7'
    containers: {
      virtualCustomer: {
        image: virtualCustomerImage.properties.imageReference
        env: {
          ORDERS_PER_HOUR: {
            value: '100'
          }
          ORDER_SERVICE_URL: {
            value: 'http://${orderServiceContainer.properties.hosts[format('{0}', 'service')]}:3000/'
          }
        }
      }
    }
    connections: {
      order: {
        disableDefaultEnvVars: true
        source: orderServiceContainer.id
      }
    }
  }
}

resource virtualWorkerContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'virtual-worker'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/virtual-worker/src/main.rs#L6'
    containers: {
      virtualWorker: {
        image: virtualWorkerImage.properties.imageReference
        env: {
          MAKELINE_SERVICE_URL: {
            value: 'http://${makelineServiceContainer.properties.hosts[format('{0}', 'service')]}:3001'
          }
          ORDERS_PER_HOUR: {
            value: '100'
          }
        }
      }
    }
    connections: {
      makeline: {
        disableDefaultEnvVars: true
        source: makelineServiceContainer.id
      }
    }
  }
}

resource storeAdminRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'store-admin-route'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'aks-store-all-in-one.yaml#L498'
    kind: 'HTTP'
    rules: [
      {
        destinationContainer: {
          containerName: 'storeAdmin'
          containerPort: 8081
          resourceId: storeAdminContainer.id
        }
        matches: [
          {
            httpPath: '/'
          }
        ]
      }
    ]
  }
}

resource storeFrontRoute 'Radius.Compute/routes@2025-08-01-preview' = {
  name: 'store-front-route'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'aks-store-all-in-one.yaml#L435'
    kind: 'HTTP'
    rules: [
      {
        destinationContainer: {
          containerName: 'storeFront'
          containerPort: 8080
          resourceId: storeFrontContainer.id
        }
        matches: [
          {
            httpPath: '/'
          }
        ]
      }
    ]
  }
}
