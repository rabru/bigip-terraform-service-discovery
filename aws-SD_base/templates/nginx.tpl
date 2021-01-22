{
  "class": "AS3",
  "action": "deploy",
  "persist": true,
  "declaration": {
    "class": "ADC",
    "schemaVersion": "3.24.0",
    "id": "${tenant}",
    "${tenant}": {
      "class": "Tenant",
      "Nginx": {
        "class": "Application",
        "template": "http",
        "serviceMain": {
          "class": "Service_HTTP",
          "virtualPort": ${virtual_port},
          "shareAddresses": true,
          "virtualAddresses": [
            "${virtual_address}"
          ],
          "pool": "web_pool",
          "persistenceMethods": [],
          "profileMultiplex": {
            "bigip": "/Common/oneconnect"
          }
        },
        "web_pool": {
          "class": "Pool",
          "monitors": [
            "http"
          ],
          "members": [
            {
              "servicePort": 80,
              "addressDiscovery": "aws",
              "updateInterval": 1,
              "tagKey": "Name",
              "tagValue": "${tag_value}",
              "accessKeyId": "${aws_access_key_id}",
              "secretAccessKey": "${aws_secret_access_key}",
	      "region": "${region}"
            }
          ]
        }
      }
    }
  }
}
