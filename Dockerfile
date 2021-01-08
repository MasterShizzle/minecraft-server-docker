FROM alpine:3.9

#-------------------------------------------------------------------------------
#  Environment Variables
#-------------------------------------------------------------------------------
#ARG mc_version
#ARG forge_version

ENV JAVA_MIN_MEM=4G \
    JAVA_MAX_MEM=8G \
    MC_USER=minecraft \
    MC_USER_ID=1000 \
    MC_VANILLA=false \
    #MC_VERSION=${mc_version} \
    #FORGE_VERSION=${forge_version} \
    FORGE_INSTALLER=forge-1.12.2-14.23.5.2854-installer.jar \
    MINECRAFT_HOME=/opt/minecraft \
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

# RUN mkdir ${MINECRAFT_HOME}

# Copy in the instance folder
COPY files/skyfactory4 ${MINECRAFT_HOME}

RUN cd ${MINECRAFT_HOME} \
    && java -jar "${FORGE_INSTALLER}" --installServer \
    && echo "eula=true" > eula.txt
    # && wget https://files.minecraftforge.net/maven/net/minecraftforge/forge/"${MC_VERSION}"-"${FORGE_VERSION}"/forge-"${MC_VERSION}"-"${FORGE_VERSION}"-installer.jar \
    # && mkdir -p ${MINECRAFT_HOME}/data ${MINECRAFT_HOME}/mods ${MINECRAFT_HOME}/world

# COPY files/server.properties ${MINECRAFT_HOME}/server.properties
# COPY files/start-minecraft.sh ${MINECRAFT_HOME}/

RUN chown -R "${MC_USER}":"${MC_USER}" ${MINECRAFT_HOME} 
WORKDIR ${MINECRAFT_HOME}

VOLUME ["${MINECRAFT_HOME}/backup", "${MINECRAFT_HOME}/mods", "${MINECRAFT_HOME}/world", "${MINECRAFT_HOME}/prestige"]

COPY files/entrypoint.sh /
ENTRYPOINT ["entrypoint.sh"]

USER ${MC_USER}
CMD ["start-server"]
