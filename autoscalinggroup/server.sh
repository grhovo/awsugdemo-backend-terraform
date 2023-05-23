#Init script for systemd service
#!/bin/bash

uvicorn main:app --app-dir /usr/bin/market/ --host 0.0.0.0 --port 80 --reload