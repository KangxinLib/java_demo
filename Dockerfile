FROM gcr.io/distroless/java17-debian11

WORKDIR /app

ADD ./build/libs/demo-0.0.1-SNAPSHOT.jar ./app.jar

ADD ./contrast_security.yaml ./contrast_security.yaml

ADD ./contrast.jar ./contrast.jar

CMD ["/app","-c","java -javaagent:./contrast.jar -Dcontrast.config.path=contrast_security.yaml -jar app.jar"]
