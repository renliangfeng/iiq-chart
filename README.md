Deploy IdentityIQ to Kubernetes via Helm Chart
================================

# Summary
In this example, we will demonstrate how to use Helm Chart to deploy the IdentityIQ docker image to a simulated Kubernetes cluster in Docker Desktop installed locally. 

With some modification, this Helm Chart can be enchanced to support the Production-Ready Kubernetes cloud service (e.g. AWS EKS or Azure AKS).

# Prerequisites
- **Install Docker Desktop**

  Refer to [https://www.docker.com/products/docker-desktop/](url)

  Make sure Docker Desktop is running with **Kuberneters enabled**.
- **Build IdentityIQ docker image** 
  
  Refer to [https://github.com/renliangfeng/iiq-docker](url)

- **Install local MySQL database**

  Refer to instruction from SailPoint IdentityIQ document.
- **Publish IdentityIQ docker image**
     
  Once the IdentityIQ docker image is built, it needs to be pushed to the docker registry so that Helm Chart can pull the image and deploy it to Kubernates cluster (will be discussed in the following section). In this example, I will use a local docker registry solution that is inspired by the following website ([https://docs.docker.com/registry/deploying](url)). However if you want to use other registry, you just need to update the value of ***image:repository*** in the YAML file ***values.yaml***. Run the following command to create a local docker registry for the first time:

```
docker run -d -p 5000:5000 --restart=always --name registry registry:2
```

  Now run the following commands to tag the image
```
docker tag iiq-image localhost:5000/iiq-image:v1
docker push localhost:5000/iiq-image:v1
```

Note: you may have used a different image namen than iiq-image to build the docker image, or have a different docker registry. In either case, please update the above commands accordingly.

# Run IdentityIQ in Kubernetes (Docker Desktop)
## volumns & volumnMounts
2 types of volumns are used in this solution: configMap and hostPath.
### configMap
To makes the IdentityIQ Docker image environment agnostic and portable, the docker built from the previous steps does not include ***iiq.properties*** file in the application folder. So we will need to mount the *iiq.properties* (or *log4j2.properties*) to the path defined in Kubernetes volumns via ConfigMap so that the application can access these files. These environment specific configuration files (such as *iiq.properties*, *log4j2.properties*) are stored under the subfolder (such as sandbox, dev, test etc.) of "*env*" folder. Configure the proper values of *iiq.properties* for the enviroment (we use sandbox in the demo) you are going to run. 

### hostPath
The hostPath Volumn is used to mount the following 2 directories in the host to the corresponding mountPath defined in Kubernates:
- **keystore**
  
   Create a new directory (e.g. */Users/bruce.ren/Desktop/share-config/sailpoint/keystore*) in local computer.
   Then modify the file ***env/sandbox/values.yaml*** to update the corresponding field to reflect the location.
- **log file directory** 

   Create a new directory (e.g. */Users/bruce.ren/Desktop/share-config/sailpoint/logs*) in local computer.
   Then modify the file **env/sandbox/values.yaml** to update the corresponding field to reflect the location. Please note once this is configured, all the log files (both log4j and tomcat generated) will be written to this folder.
For the first time, create the following 2 directories in local machine:


## Install Helm Chart
Run the following command to deploy the IdentityIQ to Kubernetes cluster.

```
./deploy.sh sandbox
```

Run the following command to check if deployment is successful.

```
kubectl get pod --namespace=iiq
```

If deployment is successful, you should be able to access the application with the following URL:
- [http://localhost/identityiq](url)
