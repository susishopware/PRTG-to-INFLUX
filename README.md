# PRTG to InfluxDB (AWS Timestream) Connector Script

This PowerShell script fetches monitoring data from a PRTG Network Monitor instance and sends it to an InfluxDB database, specifically designed for use with AWS Timestream for InfluxDB. The script can also function as a PRTG Custom EXEXML Sensor, reporting the number of data points processed.

## Features

- Connects to PRTG API to retrieve channel data.
- Authenticates with PRTG using username/password to obtain a session token.
- Formats data into InfluxDB Line Protocol.
- Sends data to InfluxDB v2 API (compatible with AWS Timestream for InfluxDB).
- Authenticates with InfluxDB using a token.
- Handles pagination when fetching data from PRTG (currently fetches in batches of 3000).
- Skips data points older than 30 days or those without recent measurements.
- Includes basic error handling for InfluxDB write operations.
- Can output XML in PRTG Custom EXEXML Sensor format, reporting the total number of elements processed.

## Prerequisites

- PowerShell.
- Access to a PRTG Network Monitor instance with API enabled.
- An InfluxDB instance (v2 API compatible, e.g., AWS Timestream for InfluxDB) with:
  - A pre-configured bucket.
  - An organization ID.
  - An authentication token with write access to the bucket.

## Configuration

Before running the script, you need to update the following variables at the beginning of `prtg_influx_v2-aws.ps1`:

**InfluxDB Settings:**

- `$InfluxDBServer`: The URL of your InfluxDB/Timestream instance (e.g., `https://your-timestream-url.eu-central-1.timestream-influxdb.amazonaws.com:8086`).
- `$InfluxBucket`: The name of your InfluxDB bucket (e.g., `"prtg"`).
- `$InfluxToken`: Your InfluxDB authentication token.
- `$InfluxUrl`: This is constructed using the variables above, but ensure your InfluxDB Organization ID is correctly set within this URL string: `"$InfluxDBServer/api/v2/write?orgID=YOUR_ORG_ID&bucket=$InfluxBucket&precision=s"`. Replace `YOUR_ORG_ID` with your actual InfluxDB organization ID.

**PRTG Settings:**

- `$PRTGUrl`: The API URL of your PRTG instance (e.g., `https://your.prtg.server:port/api/v2`).
- In the line `$PRTGToken = (Invoke-RestMethod ...)`:
  - Replace `"XXX"` in `{"username": "XXX", ...}` with your PRTG API username.
  - Replace `"XXX"` in `..., "password": "XXX"}` with your PRTG API password.

## Usage

1.  **Configure the script:** Update the InfluxDB and PRTG variables as described above.
2.  **Run the script:** Execute the PowerShell script from a PowerShell terminal:
    ```powershell
    .\prtg_influx_v2-aws.ps1
    ```
3.  **As a PRTG Custom Sensor:**
    - Place the script on your PRTG probe machine.
    - Create a new "EXE/Script Advanced" sensor in PRTG.
    - Point the sensor to this PowerShell script.
    - The script will output XML that PRTG can interpret, showing a channel named "Elemente" with the count of data points processed.

## Data Fetching and Processing

- The script fetches data in batches (currently 7 batches of 3000, totaling up to 21,000 channels). If you have more channels, you may need to add more `Invoke-RestMethod` blocks or implement a more dynamic looping mechanism.
- Channel names and values containing spaces or commas are escaped before being sent to InfluxDB.
- Timestamps are converted to Unix epoch seconds.
- Data older than 30 days is skipped.
- Channels with no `last_measurement` or empty `value` (which is then set to 0) are handled.

## Error Handling

- The script includes a `try-catch` block when sending data to InfluxDB. If an error occurs, an error message along with the data payload that failed will be written to the host.

## Disclaimer

- Replace placeholder values (like "XXX", PRTG URLs, InfluxDB URLs, tokens, and org IDs) with your actual configuration details before running the script.
- Ensure the PRTG user has sufficient permissions to access channel data via the API.
- Ensure the InfluxDB token has write permissions to the specified bucket.

---

_This README was generated based on the `prtg_influx_v2-aws.ps1` script._
