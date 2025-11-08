# ---------- Stage 1: Build the WAR file ----------
FROM maven:3.9.9-eclipse-temurin-17 AS build

# Set working directory inside the container
WORKDIR /app

# Copy pom.xml and download dependencies (cache optimization)
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build the WAR
COPY src ./src
RUN mvn clean package -DskipTests

# ---------- Stage 2: Run on Tomcat ----------
FROM tomcat:9.0-jdk17-temurin

# Remove default ROOT webapp from Tomcat
RUN rm -rf /usr/local/tomcat/webapps/ROOT

# Copy the built WAR from the previous stage
COPY --from=build /app/target/maven.war /usr/local/tomcat/webapps/ROOT.war

# Expose default Tomcat port
EXPOSE 8080

# Start Tomcat
CMD ["catalina.sh", "run"]
