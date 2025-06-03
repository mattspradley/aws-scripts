CREATE EXTERNAL TABLE ctrail_org_arymd (eventversion STRING,
useridentity STRUCT<
               type:STRING,
               principalid:STRING,
               arn:STRING,
               accountid:STRING,
               invokedby:STRING,
               accesskeyid:STRING,
               userName:STRING,
sessioncontext:STRUCT<
attributes:STRUCT<
               mfaauthenticated:STRING,
               creationdate:STRING>,
sessionissuer:STRUCT<
               type:STRING,
               principalId:STRING,
               arn:STRING,
               accountId:STRING,
               userName:STRING>>>,
eventtime STRING,
eventsource STRING,
eventname STRING,
awsregion STRING,
sourceipaddress STRING,
useragent STRING,
errorcode STRING,
errormessage STRING,
requestparameters STRING,
responseelements STRING,
additionaleventdata STRING,
requestid STRING,
eventid STRING,
resources ARRAY<STRUCT<
               ARN:STRING,
               accountId:STRING,
               type:STRING>>,
eventtype STRING,
apiversion STRING,
readonly STRING,
recipientaccountid STRING,
serviceeventdetails STRING,
sharedeventid STRING,
vpcendpointid STRING
)
PARTITIONED BY (account string, region string, year string, month string, day string)
ROW FORMAT SERDE
  'com.amazon.emr.hive.serde.CloudTrailSerde'
STORED AS INPUTFORMAT
  'com.amazon.emr.cloudtrail.CloudTrailInputFormat'
OUTPUTFORMAT
  'org.apache.hadoop.hive.ql.io.HiveIgnoreKeyTextOutputFormat'
LOCATION
  's3://[log location]]'
TBLPROPERTIES (
  'projection.enabled'='true',
  'projection.day.type'='integer',
  'projection.day.range'='01,31',
  'projection.day.digits'='2',
  'projection.month.type'='integer',
  'projection.month.range'='01,12',
  'projection.month.digits'='2',
  'projection.region.type'='enum',
  'projection.region.values'='us-east-1,us-east-2,us-west-1,us-west-2',
  'projection.year.type'='enum',
  'projection.year.values'='2025',
  'projection.account.type'='enum', 
  'projection.account.values'='111111111111,222222222222,333333333333',  
  'storage.location.template'='[s3://[log location]]${account}/CloudTrail/${region}/${year}/${month}/${day}/'
)