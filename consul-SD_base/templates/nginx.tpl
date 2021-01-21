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
              "addressDiscovery": "consul",
              "updateInterval": 10,
              "uri": "http://10.0.0.100:8500/v1/health/service/${tenant}?passing",
	      "jmesPathQuery": "[*].{id:Node.Address,ip:{private:Node.Address,public:Node.Address},port:Service.Port}"
            }
          ]
        }
      }
    }
  }
}
