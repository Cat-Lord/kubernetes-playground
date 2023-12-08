FROM openjdk:17-jdk-alpine
COPY ./build/libs/http-liveness-probe-test-0.0.1-SNAPSHOT.jar liveness.jar
ENTRYPOINT ["java", "-jar", "liveness.jar"]
