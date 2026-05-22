# Enable Unauthenticated Health Check

Starting with container image version 11.1.0.8, the API Gateway requires an authentication on health check (used in Readiness Probe). To disable the authentication, set the environment variable `APIGW_UNAUTHENTICATED_HEALTH_CHECK` ...

```
extraEnvs:
  - name: APIGW_UNAUTHENTICATED_HEALTH_CHECK
    value: "true"
```

See more information [here](https://www.ibm.com/docs/en/wam/wm-api-gateway/11.1.0?topic=gateway-monitoring-api-health).