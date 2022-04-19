FROM gcr.io/distroless/java17-debian11

WORKDIR /app

ADD ./build/libs/demo-0.0.1-SNAPSHOT.jar ./app.jar

ADD ./contrast_security.yaml ./contrast_security.yaml

RUN curl -L 'https://repository.sonatype.org/service/local/artifact/maven/redirect?r=central-proxy&g=com.contrastsecurity&a=contrast-agent&v=LATEST' -o contrast.jar

CMD ["java -javaagent:./contrast.jar -Dcontrast.config.path=contrast_security.yaml -jar app.jar"]
