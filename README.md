Deploy IdentityIQ to Kubernetes via Helm Chart
================================

# Summary
In this example, we will demonstrate how to use Helm Chart to deploy the IdentityIQ docker image to a simulated Kubernetes cluster in Docker Desktop installed locally. 

With some modification, this Helm Chart can be enhanced to support the production-grade Kubernetes cloud service (e.g. AWS EKS or Azure AKS).

# Prerequisites
- **Install Docker Desktop**

  Refer to [https://www.docker.com/products/docker-desktop/](url)

  Make sure Docker Desktop is running with **Kuberneters enabled**.
- **Build IdentityIQ docker image** 
  
  Refer to [https://github.com/renliangfeng/iiq-container](url)

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
To makes the IdentityIQ Docker image environment agnostic and portable, the docker built from the previous steps does not include ***iiq.properties*** file in the application folder. So we will need to mount the *iiq.properties* (or *log4j2.properties*) to the path defined in Kubernetes volumns via ConfigMap so that the application can access these files. The content of ***iiq.properties*** file is defined in the template file ***template/iiq.properties.tpl***. You should modify this file to update the settings across all the environments. However, environment specific configuration settings in ***iiq.properties*** (such as Database URL, username and password etc.) should be overridden via ***values.yaml*** under the subfolder (such as sandbox, dev, test etc.) of "*env*" folder. Configure the proper values of *values.yaml* for the enviroment (we use sandbox in the demo) you are going to run. 

### hostPath
The hostPath Volume is used to mount the following directories in the host to the corresponding mountPath defined in Kubernates. For the first time, create the following directories in local machine:

- **keystore**
  
   Create a new directory (e.g. */Users/bruce.ren/Desktop/share-config/sailpoint/keystore*) in local computer.
   Then modify the file ***env/sandbox/values.yaml*** to update the corresponding field to reflect the location.

- **log file directory** 

   Create a new directory (e.g. */Users/bruce.ren/Desktop/share-config/sailpoint/logs*) in local computer.
   Then modify the file **env/sandbox/values.yaml** to update the corresponding field to reflect the location. Please note once this is configured, all the log files (both log4j and tomcat generated) will be written to this folder.

- **LCM fulltext index files directory** 

   Create a new directory (e.g. */Users/bruce.ren/Desktop/share-config/sailpoint/iiq-fulltext-index*) in local computer.
   Then modify the file **values.yaml** or **env/sandbox/values.yaml** to update the corresponding field to reflect the location. Please note the name of directory inside container is controlled by the parameter '*FULL_TEXT_INDEX_PATH*' to create Docker image. 

- **file upload directory** 

   Create a new directory (e.g. */Users/bruce.ren/Desktop/share-config/sailpoint/file-upload*) in local computer.
   Then modify the file **values.yaml** or **env/sandbox/values.yaml** to update the corresponding field to reflect the location. Please note the name of directory inside container is controlled by the parameter '*UPLOAD_FILE_PATH*' to create Docker image. 

For details about how to create directories in docker image for LCM full text index files and file upload, please refer to [https://github.com/renliangfeng/iiq-container](url). 

## Environment Variables
To configure the server time zone or Tomcat JVM Heap size settings, you should modify the file **values.yaml** or **env/sandbox/values.yaml** to update the following field values (one for UI server and other for Task server if you have both deployed to the cluster)
- servers.ui.env
- servers.task.env

## Server Hostnames
Hostname is important because IdentityIQ uses Hostname to determine if the current server is running as a Task or UI server. In a non-premise environment where Hostname of each server is a static value, this will be prefined in *ServiceDefinition* Objects (such as *Task* and *Request*). However, in a containerized environment, this presents a challenge as the hostname (name of pod in kubernetes cluster) is dynamic due to  the ephemeral nature of pod. When the old pod is destroyed and a new pod is created, a completely different pod name is allocated. The easist way to solve this problem is to use ***IIQ Autoscaling Plugin*** developed by SailPoint Professional Service. The plugin will automatically update the corresponding *ServiceDefinition* Objects based on the configured environment variables values (refer to **servers** attribute defined in the file **values.yaml**) when the pod is started or destroyed. Contact SailPoint Professional Service for more details about the use of ***IIQ Autoscaling Plugin***. If you don't want to use the plugin, you can check out the following link which may guide you to other potential solutions. Esentiall you need to find a way to allocate a unique value of ***iiq.hostname*** environment variable for each pod when it is started.

- https://community.sailpoint.com/t5/Technical-White-Papers/Best-Practices-Containerized-IdentityIQ-Deployments/ta-p/73139



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
