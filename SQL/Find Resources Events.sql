SELECT eventsource, eventname, eventtime, useridentity.accountid, resources[1].arn, requestparameters
FROM ctrail_org_arymd
WHERE year = '2025'
  AND month = '05'
  AND day = '30'
  AND region = 'us-east-1'
  AND account = '111111111111'
  AND requestparameters LIKE '%[bucket name]%'
  --AND resources[1].arn = 'arn:aws:s3:::[bucket name]'
  AND eventtime > '2025-05-30T02:00'
LIMIT 100;