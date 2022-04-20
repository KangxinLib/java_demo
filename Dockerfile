FROM gcr.io/distroless/java17-debian11

WORKDIR /home/nonroot
USER nonroot

ADD ./build/libs/demo-0.0.1-SNAPSHOT.jar /home/nonroot/app.jar

ADD ./contrast_security.yaml /home/nonroot/contrast_security.yaml

ADD ./contrast.jar /home/nonroot/contrast.jar

ENV JAVA_TOOL_OPTIONS="-javaagent:contrast.jar -Dcontrast.config.path=contrast_security.yaml -Dcontrast.log=/home/nonroot/contrast.log"

CMD ["app.jar"]
