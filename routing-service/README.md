# Open Source Routing Machine (OSRM) Backend Deployment

(based on https://github.com/franc703/osrm-backend-deploy/tree/main)
This repository contains the necessary files to deploy an OSRM-backend server using Docker and AWS. The OSRM-backend server is configured to use map data for Michigan only.

## Setting Up

```bash
docker build -t my-osrm-backend .
docker run -d -p 8080:8080 my-osrm-backend
```

## Notes

This is a memory hog. Also initial startup can take upwards of 30-40 minutes depending on your memory.
