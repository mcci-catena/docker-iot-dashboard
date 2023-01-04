# Influx Cloud Setup

To use the Influx API v1.x Endpoint (currently used by Surveyor), must have an Influx v1 DBRP (Database Retention Policy) in place. 
The DBRP maps a v1 DB name to a v2 bucket name with a retention policy.

### Example

The `influx cli` command below creates the needed mapping.

```bash
influx v1 dbrp create \
  --bucket-id 3001cad66570963c \
  --db surveyor \
  --rp surveyor \
  --default
```
Another example
```bash
influx v1 dbrp create \
  --bucket-id 834623352d10ec39 \
  --db nodedev \
  --rp nodedev \
  --default
```
