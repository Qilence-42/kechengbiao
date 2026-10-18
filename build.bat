@rem ==========================================================================
@rem 课表 - Windows 一键构建脚本
@rem
@rem 自动探测 JDK / Gradle 用户目录 / Android SDK，然后转调 gradlew.bat。
@rem
@rem 用法:
@rem   build.bat                   相当于 gradlew assembleDebug
@rem   build.bat assembleDebug     构建 Debug APK
@rem   build.bat assembleRelease   构建 Release APK
@rem   build.bat test              运行单元测试
@rem   build.bat clean             清理构建产物
@rem
@rem 环境变量（都可省略，脚本会自己找）:
@rem   JAVA_HOME          JDK 17 路径
@rem   ANDROID_HOME       Android SDK 路径
@rem   GRADLE_USER_HOME   Gradle 缓存目录
@rem ==========================================================================
@echo off
setlocal

set "APP_HOME=%~dp0"
cd /d "%APP_HOME%"

@rem ---- 1) JDK：优先 JAVA_HOME，其次 Android Studio 自带 JBR，最后常见安装位置 ----
if not defined JAVA_HOME (
  if exist "%LOCALAPPDATA%\Programs\Android Studio\jbr\bin\java.exe" (
    set "JAVA_HOME=%LOCALAPPDATA%\Programs\Android Studio\jbr"
  )
)
if not defined JAVA_HOME (
  if exist "%ProgramFiles%\Android\Android Studio\jbr\bin\java.exe" (
    set "JAVA_HOME=%ProgramFiles%\Android\Android Studio\jbr"
  )
)
if not defined JAVA_HOME (
  if exist "%ProgramFiles%\Java\jdk-17\bin\java.exe" (
    set "JAVA_HOME=%ProgramFiles%\Java\jdk-17"
  )
)

@rem ---- 2) Android SDK：优先 ANDROID_HOME，其次 local.properties 的 sdk.dir，最后默认路径 ----
if not defined ANDROID_HOME (
  if exist "%APP_HOME%local.properties" (
    for /f "tokens=1,* delims==" %%a in ('findstr /b /c:"sdk.dir" "%APP_HOME%local.properties" 2^>nul') do set "SDKLINE=%%b"
  )
)
if not defined ANDROID_HOME if defined SDKLINE set "ANDROID_HOME=%SDKLINE:\=%"
if not defined ANDROID_HOME if exist "%LOCALAPPDATA%\Android\Sdk" set "ANDROID_HOME=%LOCALAPPDATA%\Android\Sdk"

echo [build.bat] JAVA_HOME        = %JAVA_HOME%
echo [build.bat] ANDROID_HOME     = %ANDROID_HOME%
if defined GRADLE_USER_HOME echo [build.bat] GRADLE_USER_HOME = %GRADLE_USER_HOME%

@rem ---- 3) 转调 gradlew ----
if "%~1"=="" (
  call "%APP_HOME%gradlew.bat" assembleDebug
) else (
  call "%APP_HOME%gradlew.bat" %*
)
set "RC=%ERRORLEVEL%"
endlocal & exit /b %RC%
