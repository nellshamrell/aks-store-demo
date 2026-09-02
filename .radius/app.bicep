extension radius

param environment string

@secure()
param rabbitMqPassword string

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
    codeReference: 'src/makeline-service/mongodb.go#L149'
    database: 'orderdb'
  }
}

resource rabbitMq 'Radius.Messaging/rabbitMQ@2025-08-01-preview' = {
  name: 'rabbitmq'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/order-service/plugins/messagequeue.js#L26'
    password: rabbitMqSecret.id
    queue: 'orders'
    username: 'username'
  }
}

resource rabbitMqSecret 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'rabbitmq-credentials'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/order-service/plugins/messagequeue.js#L29'
    data: {
      password: {
        value: rabbitMqPassword
      }
    }
  }
}

resource registryCreds 'Radius.Security/secrets@2025-08-01-preview' = {
  name: 'radius-ghcr-registry-creds'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: '.github/workflows/package-order-service.yaml#L49'
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

resource makelineImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'makeline-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/makeline-service/Dockerfile#L1'
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nellshamrell/aks-store-demo.git//src/makeline-service?ref=0e254cc3f9837cf03e1b165db01768e012e0aace'
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource orderImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'order-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/order-service/Dockerfile#L1'
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nellshamrell/aks-store-demo.git//src/order-service?ref=0e254cc3f9837cf03e1b165db01768e012e0aace'
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource productImage 'Radius.Compute/containerImages@2025-08-01-preview' = {
  name: 'product-service-image'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/product-service/Dockerfile#L1'
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nellshamrell/aks-store-demo.git//src/product-service?ref=0e254cc3f9837cf03e1b165db01768e012e0aace'
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
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nellshamrell/aks-store-demo.git//src/store-admin?ref=0e254cc3f9837cf03e1b165db01768e012e0aace'
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
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nellshamrell/aks-store-demo.git//src/store-front?ref=0e254cc3f9837cf03e1b165db01768e012e0aace'
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
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nellshamrell/aks-store-demo.git//src/virtual-customer?ref=0e254cc3f9837cf03e1b165db01768e012e0aace'
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
    build: {
      platforms: [
        'linux/amd64'
      ]
      source: 'git::https://github.com/nellshamrell/aks-store-demo.git//src/virtual-worker?ref=0e254cc3f9837cf03e1b165db01768e012e0aace'
    }
  }
  dependsOn: [
    registryCreds
  ]
}

resource makelineContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'makeline-service'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/makeline-service/main.go#L21'
    containers: {
      makelineService: {
        image: makelineImage.properties.imageReference
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
                secretName: rabbitMqSecret.name
                key: 'password'
              }
            }
          }
          ORDER_QUEUE_URI: {
            value: 'amqp://${rabbitMq.properties.host}:${rabbitMq.properties.port}'
          }
          ORDER_QUEUE_USERNAME: {
            value: 'username'
          }
        }
        ports: {
          web: {
            containerPort: 3001
          }
        }
      }
    }
  }
}

resource orderContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'order-service'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/order-service/app.js#L6'
    containers: {
      orderService: {
        image: orderImage.properties.imageReference
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
                secretName: rabbitMqSecret.name
                key: 'password'
              }
            }
          }
          ORDER_QUEUE_PORT: {
            value: '${rabbitMq.properties.port}'
          }
          ORDER_QUEUE_USERNAME: {
            value: 'username'
          }
        }
        ports: {
          web: {
            containerPort: 3000
          }
        }
      }
    }
  }
}

resource productContainer 'Radius.Compute/containers@2025-08-01-preview' = {
  name: 'product-service'
  properties: {
    environment: environment
    application: aksStoreDemoApp.id
    codeReference: 'src/product-service/src/main.rs#L5'
    containers: {
      productService: {
        image: productImage.properties.imageReference
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
        command: [
          '/bin/sh'
          '-c'
        ]
        args: [
          'sed -i "s/makeline-service/$MAKELINE_SERVICE_HOST/g; s/order-service/$ORDER_SERVICE_HOST/g; s/product-service/$PRODUCT_SERVICE_HOST/g" /etc/nginx/conf.d/default.conf && exec nginx -g "daemon off;"'
        ]
        env: {
          MAKELINE_SERVICE_HOST: {
            value: makelineContainer.properties.hosts[format('{0}', 'makelineService')]
          }
          ORDER_SERVICE_HOST: {
            value: orderContainer.properties.hosts[format('{0}', 'orderService')]
          }
          PRODUCT_SERVICE_HOST: {
            value: productContainer.properties.hosts[format('{0}', 'productService')]
          }
        }
        ports: {
          web: {
            containerPort: 8081
          }
        }
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
        command: [
          '/bin/sh'
          '-c'
        ]
        args: [
          'sed -i "s/order-service/$ORDER_SERVICE_HOST/g; s/product-service/$PRODUCT_SERVICE_HOST/g" /etc/nginx/conf.d/default.conf && exec nginx -g "daemon off;"'
        ]
        env: {
          ORDER_SERVICE_HOST: {
            value: orderContainer.properties.hosts[format('{0}', 'orderService')]
          }
          PRODUCT_SERVICE_HOST: {
            value: productContainer.properties.hosts[format('{0}', 'productService')]
          }
        }
        ports: {
          web: {
            containerPort: 8080
          }
        }
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
            value: '30'
          }
          ORDER_SERVICE_URL: {
            value: 'http://${orderContainer.properties.hosts[format('{0}', 'orderService')]}:3000/'
          }
        }
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
            value: 'http://${makelineContainer.properties.hosts[format('{0}', 'makelineService')]}:3001'
          }
          ORDERS_PER_HOUR: {
            value: '20'
          }
        }
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
          resourceId: storeAdminContainer.id
          containerName: 'storeAdmin'
          containerPort: 8081
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
          resourceId: storeFrontContainer.id
          containerName: 'storeFront'
          containerPort: 8080
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
