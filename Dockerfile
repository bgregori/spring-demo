## 4. Two-stage image builds (stage 1: builder image)
FROM maven:3.6.3-jdk-11 as builder
WORKDIR /app
COPY pom.xml .
RUN mvn -e -B dependency:resolve
COPY src ./src
RUN mvn clean -e -B package


## 4. Two-stage image builds (stage 2: deployment image)
## 1. Universal Base Image (UBI)
FROM registry.access.redhat.com/ubi8/openjdk-11:1.3-15

## 2. Non-root, arbitrary user IDs
#USER 1001  # Or USER default; or nothing, the UBI already set the user

## 6. Image identification
#LABEL name="my-namespace/my-image-name" \
#      vendor="My Company, Inc." \
#      version="1.2.3" \
#      release="45" \
#      summary="Web search application" \
#      description="This application searches the web for interesting stuff."

USER root

## 7. Image license
#COPY ./licenses /licenses

## 5. Latest security updates
RUN dnf -y update-minimal --security --sec-severity=Important --sec-severity=Critical && \
    dnf clean all

USER 1001  

## 3. Group ownership and file permission
#RUN chown -R 1001:0 /some/directory && \
#    chmod -R g=u /some/directory

COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]