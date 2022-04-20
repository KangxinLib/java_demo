FROM gcr.io/distroless/java17-debian11:nonroot

WORKDIR /home/nonroot
USER nonroot

COPY --chown=nonroot:nonroot ./build/libs/demo-0.0.1-SNAPSHOT.jar ./app.jar

COPY --chown=nonroot:nonroot ./contrast_security.yaml ./contrast_security.yaml

COPY --chown=nonroot:nonroot ./contrast.jar ./contrast.jar

ENV JAVA_TOOL_OPTIONS="-javaagent:contrast.jar -Dcontrast.config.path=contrast_security.yaml -Dcontrast.log=/home/nonroot/contrast.log"

CMD ["app.jar"]
