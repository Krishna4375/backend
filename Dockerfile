# ----- Stage 1: Build the Application -----
# Use an official Maven image with Java 17
FROM maven:3.9-eclipse-temurin-17 AS build

# Set the working directory inside the container
WORKDIR /app

# Copy the pom.xml first to leverage Docker layer caching
# This way, dependencies are only re-downloaded if pom.xml changes
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the rest of your source code
COPY src ./src

# Package the application, skipping tests (they should be run in a CI pipeline)
RUN mvn package -DskipTests

# ----- Stage 2: Create the Final Runtime Image -----
# Use a lightweight Java 17 Runtime image
FROM eclipse-temurin:17-jre-alpine

# Set the working directory
WORKDIR /app

# Copy only the built .jar file from the 'build' stage
# The path in target/ might be different if you have a custom artifactId
COPY --from=build /app/target/backend-0.0.1-SNAPSHOT.jar app.jar

# Expose the port your Spring Boot app runs on (default is 8080)
EXPOSE 8080

# The command to run your application
ENTRYPOINT ["java", "-jar", "app.jar"]