@rem Gradle wrapper for the "KechengBiao" Android project (Windows).
@rem Prefers the JDK bundled in .tools/jdk, then JAVA_HOME, then java on PATH.
@echo off
setlocal

set DIRNAME=%~dp0
if "%DIRNAME%"=="" set DIRNAME=.\
set APP_HOME=%DIRNAME%
set APP_BASE_NAME=%~n0
set CLASSPATH=%APP_HOME%gradle\wrapper\gradle-wrapper.jar

if not defined JAVA_HOME (
  for /d %%i in ("%APP_HOME%.tools\jdk\*") do (
    if exist "%%i\bin\java.exe" set "JAVA_HOME=%%i"
  )
)

if defined JAVA_HOME (
  set "JAVA_EXE=%JAVA_HOME%\bin\java.exe"
) else (
  set "JAVA_EXE=java.exe"
)

"%JAVA_EXE%" -Dorg.gradle.appname=%APP_BASE_NAME% -classpath "%CLASSPATH%" org.gradle.wrapper.GradleWrapperMain %*

endlocal
