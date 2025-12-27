@echo off
echo Building qBittorrent with WireGuard fixes...

docker build -t qbittorrent-fixed:test .

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build successful!
    echo.
    echo To test, create a config directory and run:
    echo docker run -d --name qbt-test --cap-add=NET_ADMIN --device=/dev/net/tun -v %cd%\test-config:/config -v %cd%\downloads:/share -p 8080:8080 qbittorrent-fixed:test
    echo.
    echo Then check logs with: docker logs qbt-test
) else (
    echo Build failed!
)