resource_group_name     = "tfResourceGroup1"
location                = "East US"
acr_name                = "c2cacr"
acr_resource_group_name = "c2c-demo"
acr_login_server        = "c2cacr.azurecr.io"
acr_admin_username      = "c2cacr"
acr_admin_password      = "+ZIQpusAzJ7K4N5JrAxb/CQl+qFQXjqElGZhgD1Q/c+ACRDTs9wC"

container_apps = [
  {
    name       = "benoenv"
    image_name = "c2c-be-external"
    image_tag  = "latest"
    port       = 8000
  }
]

env_vars = [
 {
  name  = "DEBUG"
  value = "True"
},
{
  name  = "MONTHLY"
  value = "monthly"
},
{
  name  = "YEARLY"
  value = "yearly"
},
{
  name  = "BI_WEEKLY"
  value = "biweekly"
},
{
  name  = "QUARTERLY"
  value = "quarterly"
},
{
  name  = "ACTIVE"
  value = "active"
},
{
  name  = "INACTIVE"
  value = "inactive"
},
{
  name  = "POTENTIAL_LEAD"
  value = "potential lead"
},
{
  name  = "ONBOARDED"
  value = "onboarded"
},
{
  name  = "US"
  value = "US"
},
{
  name  = "LATAM"
  value = "LATAM"
},
{
  name  = "IND"
  value = "IND"
},
{
  name  = "EUR"
  value = "EUR"
},
{
  name  = "USD"
  value = "USD"
},
{
  name  = "INR"
  value = "INR"
},
{
  name  = "EMPLOYEE"
  value = "EMPLOYEE"
},
{
  name  = "CONTRACTOR"
  value = "CONTRACTOR"
},
{
  name  = "EMPLOYEE_HOURLY"
  value = "EMPLOYEE_HOURLY"
},
{
  name  = "SUB_CONTRACTOR"
  value = "SUB_CONTRACTOR"
},
{
  name  = "ACCOUNT_URL"
  value = "BlobEndpoint=https://c2cdemofilestorage.blob.core.windows.net/;QueueEndpoint=https://c2cdemofilestorage.queue.core.windows.net/;FileEndpoint=https://c2cdemofilestorage.file.core.windows.net/;TableEndpoint=https://c2cdemofilestorage.table.core.windows.net/;SharedAccessSignature=sv=2022-11-02&ss=b&srt=co&sp=rwlaciytfx&se=2026-11-26T04:13:19Z&st=2024-11-25T20:13:19Z&spr=https&sig=bmHHlXruk%2FzSz1vrVJZlD8p8rwILT0uS5PGhS9V4Sf4%3D"
},
{
  name  = "AZURE_CONTAINER_NAME"
  value = "brl-filestorage-docs-container"
},
{
  name  = "AZURE_CONNECTION_STRING"
  value = "BlobEndpoint=https://c2cdemofilestorage.blob.core.windows.net/;QueueEndpoint=https://c2cdemofilestorage.queue.core.windows.net/;FileEndpoint=https://c2cdemofilestorage.file.core.windows.net/;TableEndpoint=https://c2cdemofilestorage.table.core.windows.net/;SharedAccessSignature=sv=2022-11-02&ss=b&srt=co&sp=rwlaciytfx&se=2026-11-26T04:13:19Z&st=2024-11-25T20:13:19Z&spr=https&sig=bmHHlXruk%2FzSz1vrVJZlD8p8rwILT0uS5PGhS9V4Sf4%3D"
},
{
  name  = "AUTH_API"
  value = "https://auth-service.blackstone-feec0b94.eastus.azurecontainerapps.io/auth_service/"
},
{
  name  = "PROFILE"
  value = "DEMO"
},
{
  name  = "MPS_DOCUMENT_PARSER_API"
  value = "https://brl-c2c-document-parser.blackstone-feec0b94.eastus.azurecontainerapps.io/"
},
{
  name  = "OPENAI_API"
  value = "http://127.0.0.1:5000/"
},
{
  name  = "SCHEDULER_DAY"
  value = "mon"
},
{
  name  = "SCHEDULER_HOUR"
  value = "18"
},
{
  name  = "SCHEDULER_MINUTE"
  value = "0"
},
{
  name  = "SCHEDULER_TIMEZONE"
  value = "Asia/Kolkata"
},
{
  name  = "BUDGETO123"
  value = "BUDGETO123"
}
]

db_server_name = "budgeto"
db_username    = "adminuser"
db_password    = "H@Sh1CoR3!"
db_name        = "saasdb"