# C1WS_Agent_Report

AUTHOR		: Yanni Kashoqa

TITLE		: Cloud One Workload Security Agent Information Report

DESCRIPTION	: This Powershell script will generate a report on the the agents and their status in Cloud One Workload Security

FEATURES
- Generate a report on the the agents and their status in Cloud One Workload Security

REQUIRMENTS
- PowerShell 6+
- Create a TM-Config.json in the same folder with the following content:
~~~~JSON
{
    "MANAGER": "workload.us-1.cloudone.trendmicro.com",
    "APIKEY" : "ApiKey YourAPIKey",
    "REPORTNAME" : "C1WS_Agent_Report",
    "POLICYID" : ""
}
~~~~

- An API Key created on the Cloud One console
- The API Key Role minimum requirement is Read Only access to Workload Security
- The API Key format in the TM-Config.json is "ApiKey YourAPIKey"
- POLICYID can be blank which will generate a report of all systems
- If POLICYID is used the report will only include systems using this Policy ID number