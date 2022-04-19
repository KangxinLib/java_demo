FROM openjdk:17-alpine

WORKDIR /app

ADD ./build/libs/demo-0.0.1-SNAPSHOT.jar ./app.jar

ADD ./contrast_security.yaml ./contrast_security.yaml

ADD ./contrast.jar ./contrast.jar

CMD java -jar app.jar
