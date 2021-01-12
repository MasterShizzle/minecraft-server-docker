FROM alpine:3.9

#-------------------------------------------------------------------------------
#  Environment Variables
#-------------------------------------------------------------------------------

ENV JAVA_MIN_MEM=4G \
    JAVA_MAX_MEM=8G \
    MC_USER=minecraft \
    MC_USER_ID=1000 \
    MC_VANILLA=false \
    FORGE_INSTALLER=forge-1.12.2-14.23.5.2854-installer.jar \
    MINECRAFT_HOME=/opt/minecraft \
    INSTANCE_HOME=files/sf4-dadland35e \
    JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

EXPOSE 25565

#-------------------------------------------------------------------------------
#  Add Minecraft user
#-------------------------------------------------------------------------------
RUN addgroup -g "$MC_USER_ID" "$MC_USER" \
    && adduser \
    -D -G "$MC_USER" \
    -u "$MC_USER_ID" \
    "$MC_USER"

#-------------------------------------------------------------------------------
#  Download and configure Minecraft/Forge
#-------------------------------------------------------------------------------
RUN apk update && apk upgrade \
    && apk add openjdk8 wget curl bash

# Instance folder holding the server / world files
RUN mkdir -p ${MINECRAFT_HOME}
COPY ${INSTANCE_HOME} ${MINECRAFT_HOME}
RUN chown -R "${MC_USER}":"${MC_USER}" ${MINECRAFT_HOME} 

RUN cd "$MINECRAFT_HOME" \
    && cat /etc/resolv.conf \
    && java -jar "$FORGE_INSTALLER" --installServer \
    && echo "eula=true" > eula.txt

WORKDIR ${MINECRAFT_HOME}

VOLUME ${MINECRAFT_HOME}

COPY files/entrypoint.sh /
ENTRYPOINT ["/bin/bash", "/entrypoint.sh"]

USER ${MC_USER}
RUN cat server.properties
CMD ["/bin/sh", "./start-server"]
