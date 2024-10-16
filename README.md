Testing Interaction Between .NET and JanusGraph

This "Hello World" project is meant to demonstrate how to start JanusGraph with a Cassandra backend and Elasticsearch in a Docker environment, then connect to it using the C# GremlinClient.

### Running the Setup

1. **Open a Terminal:**
   Make sure you have a terminal or command prompt open and navigate to the root directory of this project where the `docker-compose.yml` file is located.

2. **Start the Containers:**
   Run the following command to start the Docker containers in detached mode:

   ```bash
   docker-compose up -d
   ```

   This command will build and start the containers defined in the `docker-compose.yml` file.

3. **Verify Container Status:**
   After the command has successfully executed, check if all the containers are running by executing:

   ```bash
   docker-compose ps
   ```

   Ensure that all containers show a status of "Up." If any containers are not running, you may need to check the logs for troubleshooting.

4. **Run the `MyJanusGraphApp` Project:**
   Open a new terminal, navigate to the `MyJanusGraphApp` project directory. Then, run the following commands to build and run the application:

   ```bash
   dotnet build
   dotnet run
   ```

   If the query is successful, you will see the example result response from JanusGraph in the terminal.

5. **Stopping and Removing Containers (Optional):**
   If you wish to stop and remove the containers after you are done, you can execute the following commands:

   ```bash
   docker-compose down
   ```

   This command will stop and remove the containers defined in the `docker-compose.yml` file.

6. **List All Docker Containers:**
   To see a list of all containers (including stopped ones), run:

   ```bash
   docker ps -a
   ```

7. **Remove Specific Containers (if needed):**
   If you want to remove specific containers, you can use the following command, replacing `<Container ID>` with the actual ID of the container you want to remove:

   ```bash
   docker rm <Container ID>
   ```

   Note: Make sure the container is stopped before you attempt to remove it.

### Additional Notes:
- Ensure that Docker is installed and running on your machine before starting these steps.
- If you encounter any errors, check the logs of the containers using `docker-compose logs` to troubleshoot.
- You can always restart the containers using `docker-compose up -d` again after stopping them. 
