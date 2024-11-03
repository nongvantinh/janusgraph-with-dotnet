For docker compose example, please see branch 1.0:

---

# Testing Interaction Between .NET and JanusGraph

This "Hello World" project demonstrates how to set up JanusGraph with a Cassandra backend and Elasticsearch in a Kubernetes environment, then connect to it using the C# GremlinClient.

## Prerequisites
- **Minikube**: Installed and running.
- **Kubernetes CLI (kubectl)**: Installed and configured for local Minikube usage.
- **.NET SDK**: Installed for running the C# application.

## Running the Setup

1. **Start Minikube and Enable the Tunnel**
   Open a terminal, then start Minikube and set up the tunnel to allow access to your Kubernetes services.

   ```bash
   minikube start
   minikube tunnel
   ```

   > **Note**: The tunnel command must be kept running in a separate terminal while you are working with the services.

2. **Deploy the JanusGraph, Cassandra, and Elasticsearch Stack**
   With the Minikube tunnel running, open a new terminal tab or window and deploy the required Kubernetes resources:

   ```bash
   kubectl apply -f janusgraph-cassandra-elasticsearch.yaml
   ```

3. **Verify Pods are Running**
   After deploying, check that all pods are up and running:

   ```bash
   kubectl get pods
   ```

   You should see output similar to the following:

   ```
   NAME                          READY   STATUS    RESTARTS   AGE
   cassandra-0                   1/1     Running   0          13m
   elasticsearch-0               1/1     Running   0          13m
   janusgraph-7f84d455cd-hrtxp   1/1     Running   0          13m
   ```

   Ensure each pod status is "Running." If not, refer to the troubleshooting section below.

4. **Access Services Locally**
   To access the JanusGraph, Elasticsearch, and Cassandra services locally, use the following port-forwarding commands in a separate terminal window:

   ```bash
   kubectl port-forward service/janusgraph 8182:8182 &
   kubectl port-forward service/elasticsearch 9200:9200 &
   kubectl port-forward service/cassandra 9042:9042 &
   ```

5. **Run the .NET Application**
   Navigate to the `MyJanusGraphApp` project directory and build and run the C# application:

   ```bash
   cd MyJanusGraphApp
   dotnet build
   dotnet run
   ```

   If successful, the terminal will display a sample response from JanusGraph.

6. **Clean Up**
   To delete the resources when finished, run:

   ```bash
   kubectl delete -f janusgraph-cassandra-elasticsearch.yaml
   ```

## Troubleshooting

If you encounter issues during setup, here are some common solutions:

### 1. Pods in "CrashLoopBackOff" or "OOMKilled" Status
   If any pods (such as Cassandra or Elasticsearch) fail to start and show "CrashLoopBackOff" or "OOMKilled" statuses, it is likely due to insufficient memory.

   **Solution**:
   - Edit the `janusgraph-cassandra-elasticsearch.yaml` file to reduce the memory requirements for Cassandra and Elasticsearch:
     ```yaml
     env:
       - name: MAX_HEAP_SIZE
         value: "512M"
       - name: HEAP_NEWSIZE
         value: "100M"
     ```

   - For Elasticsearch, set:
     ```yaml
     env:
       - name: ES_JAVA_OPTS
         value: "-Xms512m -Xmx512m"
     ```

   - Reapply the changes:
     ```bash
     kubectl apply -f janusgraph-cassandra-elasticsearch.yaml
     ```

### 2. Unable to Connect to Services
   If the application is unable to connect to JanusGraph or other services:
   - Ensure all services are port-forwarded correctly.
   - Verify that each service is accessible by using:
     ```bash
     curl http://localhost:8182  # JanusGraph
     curl http://localhost:9200  # Elasticsearch
     ```

### 3. Checking Pod Logs
   For further troubleshooting, view the logs of any failing pod to diagnose issues:

   ```bash
   kubectl logs <pod-name>
   ```

