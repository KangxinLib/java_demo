FROM gcr.io/distroless/java17-debian11

WORKDIR /app

ADD ./build/libs/demo-0.0.1-SNAPSHOT.jar ./app.jar

CMD ["app.jar"]
