FROM openjdk:17.0.2-jdk

WORKDIR /home
#USER nonroot

COPY ./build/libs/demo-0.0.1-SNAPSHOT.jar ./app.jar

COPY ./contrast_security.yaml ./contrast_security.yaml

COPY ./contrast.jar ./contrast.jar

#ENV JAVA_TOOL_OPTIONS="-javaagent:contrast.jar -Dcontrast.config.path=contrast_security.yaml -Dcontrast.log=/home/nonroot/contrast.log"

CMD java -javaagent:contrast.jar -Dcontrast.config.path=contrast_security.yaml -Dcontrast.log=/home/contrast.log -jar app.jar

#CMD ["app.jar"]
