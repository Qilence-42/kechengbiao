#!/bin/sh
# 课表 - Gradle Wrapper (Unix)
APP_HOME=$(cd "$(dirname "$0")" && pwd)

if [ -z "$JAVA_HOME" ]; then
  for d in "$APP_HOME"/.tools/jdk/*; do
    if [ -x "$d/bin/java" ]; then
      JAVA_HOME="$d"
      break
    fi
  done
fi

if [ -n "$JAVA_HOME" ]; then
  JAVA_EXE="$JAVA_HOME/bin/java"
else
  JAVA_EXE="java"
fi

CLASSPATH="$APP_HOME/gradle/wrapper/gradle-wrapper.jar"

exec "$JAVA_EXE" -Dorg.gradle.appname=kechengbiao -classpath "$CLASSPATH" org.gradle.wrapper.GradleWrapperMain "$@"
