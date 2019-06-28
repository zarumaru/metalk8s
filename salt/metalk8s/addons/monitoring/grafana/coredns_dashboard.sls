#!kubernetes kubeconfig=/etc/kubernetes/admin.conf&context=kubernetes-admin@kubernetes
apiVersion: v1
kind: ConfigMap
metadata:
  name: grafana-dashboard-coredns
  namespace: monitoring
data:
  coredns.json: |-
    {
        "__inputs": [
          {
            "name": "DS_PROMETHEUS",
            "label": "Prometheus",
            "description": "",
            "type": "datasource",
            "pluginId": "prometheus",
            "pluginName": "Prometheus"
          }
        ],
        "__requires": [
          {
            "type": "grafana",
            "id": "grafana",
            "name": "Grafana",
            "version": "4.4.3"
          },
          {
            "type": "panel",
            "id": "graph",
            "name": "Graph",
            "version": ""
          },
          {
            "type": "datasource",
            "id": "prometheus",
            "name": "Prometheus",
            "version": "1.0.0"
          }
        ],
        "annotations": {
          "list": []
        },
        "editable": true,
        "gnetId": 5926,
        "graphTooltip": 0,
        "hideControls": false,
        "id": null,
        "links": [],
        "rows": [
          {
            "collapse": false,
            "height": "250px",
            "panels": [
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "${DS_PROMETHEUS}",
                "editable": true,
                "error": false,
                "fill": 1,
                "grid": {},
                "id": 1,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 2,
                "links": [],
                "nullPointMode": "connected",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [
                  {
                    "alias": "total",
                    "yaxis": 2
                  }
                ],
                "spaceLength": 10,
                "span": 4,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "sum(rate(coredns_dns_request_count_total{instance=~\"$instance\"}[5m])) by (proto)",
                    "format": "time_series",
                    "intervalFactor": 2,
                    "legendFormat": "{{proto}}",
                    "refId": "A",
                    "step": 60
                  },
                  {
                    "expr": "sum(rate(coredns_dns_request_count_total{instance=~\"$instance\"}[5m]))",
                    "format": "time_series",
                    "intervalFactor": 2,
                    "legendFormat": "total",
                    "refId": "B",
                    "step": 60
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Requests (total)",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "cumulative"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "pps",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  },
                  {
                    "format": "pps",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  }
                ]
              },
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "${DS_PROMETHEUS}",
                "editable": true,
                "error": false,
                "fill": 1,
                "grid": {},
                "id": 12,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 2,
                "links": [],
                "nullPointMode": "connected",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [
                  {
                    "alias": "total",
                    "yaxis": 2
                  },
                  {
                    "alias": "other",
                    "yaxis": 2
                  }
                ],
                "spaceLength": 10,
                "span": 4,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "sum(rate(coredns_dns_request_type_count_total{instance=~\"$instance\"}[5m])) by (type)",
                    "intervalFactor": 2,
                    "legendFormat": "{{type}}",
                    "refId": "A",
                    "step": 60
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Requests (by qtype)",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "cumulative"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "pps",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  },
                  {
                    "format": "pps",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  }
                ]
              },
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "${DS_PROMETHEUS}",
                "editable": true,
                "error": false,
                "fill": 1,
                "grid": {},
                "id": 2,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 2,
                "links": [],
                "nullPointMode": "connected",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [
                  {
                    "alias": "total",
                    "yaxis": 2
                  }
                ],
                "spaceLength": 10,
                "span": 4,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "sum(rate(coredns_dns_request_count_total{instance=~\"$instance\"}[5m])) by (zone)",
                    "intervalFactor": 2,
                    "legendFormat": "{{zone}}",
                    "refId": "A",
                    "step": 60
                  },
                  {
                    "expr": "sum(rate(coredns_dns_request_count_total{instance=~\"$instance\"}[5m]))",
                    "intervalFactor": 2,
                    "legendFormat": "total",
                    "refId": "B",
                    "step": 60
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Requests (by zone)",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "cumulative"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "pps",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  },
                  {
                    "format": "pps",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  }
                ]
              },
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "${DS_PROMETHEUS}",
                "editable": true,
                "error": false,
                "fill": 1,
                "grid": {},
                "id": 10,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 2,
                "links": [],
                "nullPointMode": "connected",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [
                  {
                    "alias": "total",
                    "yaxis": 2
                  }
                ],
                "spaceLength": 10,
                "span": 6,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "sum(rate(coredns_dns_request_do_count_total{instance=~\"$instance\"}[5m]))",
                    "intervalFactor": 2,
                    "legendFormat": "DO",
                    "refId": "A",
                    "step": 40
                  },
                  {
                    "expr": "sum(rate(coredns_dns_request_count_total{instance=~\"$instance\"}[5m]))",
                    "intervalFactor": 2,
                    "legendFormat": "total",
                    "refId": "B",
                    "step": 40
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Requests (DO bit)",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "cumulative"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "pps",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  },
                  {
                    "format": "pps",
                    "logBase": 1,
                    "max": null,
                    "min": null,
                    "show": true
                  }
                ]
              },
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "${DS_PROMETHEUS}",
                "editable": true,
                "error": false,
                "fill": 1,
                "grid": {},
                "id": 9,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 2,
                "links": [],
                "nullPointMode": "connected",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [
                  {
                    "alias": "tcp:90",
                    "yaxis": 2
                  },
                  {
                    "alias": "tcp:99 ",
                    "yaxis": 2
                  },
                  {
                    "alias": "tcp:50",
                    "yaxis": 2
                  }
                ],
                "spaceLength": 10,
                "span": 3,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "histogram_quantile(0.99, sum(rate(coredns_dns_request_size_bytes_bucket{instance=~\"$instance\",proto=\"udp\"}[5m])) by (le,proto))",
                    "intervalFactor": 2,
                    "legendFormat": "{{proto}}:99 ",
                    "refId": "A",
                    "step": 60
                  },
                  {
                    "expr": "histogram_quantile(0.90, sum(rate(coredns_dns_request_size_bytes_bucket{instance=~\"$instance\",proto=\"udp\"}[5m])) by (le,proto))",
                    "intervalFactor": 2,
                    "legendFormat": "{{proto}}:90",
                    "refId": "B",
                    "step": 60
                  },
                  {
                    "expr": "histogram_quantile(0.50, sum(rate(coredns_dns_request_size_bytes_bucket{instance=~\"$instance\",proto=\"udp\"}[5m])) by (le,proto))",
                    "intervalFactor": 2,
                    "legendFormat": "{{proto}}:50",
                    "refId": "C",
                    "step": 60
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Requests (size, udp)",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "cumulative"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "bytes",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  },
                  {
                    "format": "short",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  }
                ]
              },
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "${DS_PROMETHEUS}",
                "editable": true,
                "error": false,
                "fill": 1,
                "grid": {},
                "id": 14,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 2,
                "links": [],
                "nullPointMode": "connected",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [
                  {
                    "alias": "tcp:90",
                    "yaxis": 1
                  },
                  {
                    "alias": "tcp:99 ",
                    "yaxis": 1
                  },
                  {
                    "alias": "tcp:50",
                    "yaxis": 1
                  }
                ],
                "spaceLength": 10,
                "span": 3,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "histogram_quantile(0.99, sum(rate(coredns_dns_request_size_bytes_bucket{instance=~\"$instance\",proto=\"tcp\"}[5m])) by (le,proto))",
                    "intervalFactor": 2,
                    "legendFormat": "{{proto}}:99 ",
                    "refId": "A",
                    "step": 60
                  },
                  {
                    "expr": "histogram_quantile(0.90, sum(rate(coredns_dns_request_size_bytes_bucket{instance=~\"$instance\",proto=\"tcp\"}[5m])) by (le,proto))",
                    "intervalFactor": 2,
                    "legendFormat": "{{proto}}:90",
                    "refId": "B",
                    "step": 60
                  },
                  {
                    "expr": "histogram_quantile(0.50, sum(rate(coredns_dns_request_size_bytes_bucket{instance=~\"$instance\",proto=\"tcp\"}[5m])) by (le,proto))",
                    "intervalFactor": 2,
                    "legendFormat": "{{proto}}:50",
                    "refId": "C",
                    "step": 60
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Requests (size,tcp)",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "cumulative"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "bytes",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  },
                  {
                    "format": "short",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  }
                ]
              }
            ],
            "repeat": null,
            "repeatIteration": null,
            "repeatRowId": null,
            "showTitle": false,
            "title": "Row",
            "titleSize": "h6"
          },
          {
            "collapse": false,
            "height": "250px",
            "panels": [
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "${DS_PROMETHEUS}",
                "editable": true,
                "error": false,
                "fill": 1,
                "grid": {},
                "id": 5,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 2,
                "links": [],
                "nullPointMode": "connected",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [],
                "spaceLength": 10,
                "span": 6,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "sum(rate(coredns_dns_response_rcode_count_total{instance=~\"$instance\"}[5m])) by (rcode)",
                    "intervalFactor": 2,
                    "legendFormat": "{{rcode}}",
                    "refId": "A",
                    "step": 40
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Responses (by rcode)",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "cumulative"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "pps",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  },
                  {
                    "format": "short",
                    "logBase": 1,
                    "max": null,
                    "min": null,
                    "show": true
                  }
                ]
              },
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "${DS_PROMETHEUS}",
                "editable": true,
                "error": false,
                "fill": 1,
                "grid": {},
                "id": 3,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 2,
                "links": [],
                "nullPointMode": "connected",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [],
                "spaceLength": 10,
                "span": 6,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "histogram_quantile(0.99, sum(rate(coredns_dns_request_duration_milliseconds_bucket{instance=~\"$instance\"}[5m])) by (le, job))",
                    "intervalFactor": 2,
                    "legendFormat": "99%",
                    "refId": "A",
                    "step": 40
                  },
                  {
                    "expr": "histogram_quantile(0.90, sum(rate(coredns_dns_request_duration_milliseconds_bucket{instance=~\"$instance\"}[5m])) by (le))",
                    "intervalFactor": 2,
                    "legendFormat": "90%",
                    "refId": "B",
                    "step": 40
                  },
                  {
                    "expr": "histogram_quantile(0.50, sum(rate(coredns_dns_request_duration_milliseconds_bucket{instance=~\"$instance\"}[5m])) by (le))",
                    "intervalFactor": 2,
                    "legendFormat": "50%",
                    "refId": "C",
                    "step": 40
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Responses (duration)",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "cumulative"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "ms",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  },
                  {
                    "format": "short",
                    "logBase": 1,
                    "max": null,
                    "min": null,
                    "show": true
                  }
                ]
              },
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "${DS_PROMETHEUS}",
                "editable": true,
                "error": false,
                "fill": 1,
                "grid": {},
                "id": 8,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 2,
                "links": [],
                "nullPointMode": "connected",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [
                  {
                    "alias": "udp:50%",
                    "yaxis": 1
                  },
                  {
                    "alias": "tcp:50%",
                    "yaxis": 2
                  },
                  {
                    "alias": "tcp:90%",
                    "yaxis": 2
                  },
                  {
                    "alias": "tcp:99%",
                    "yaxis": 2
                  }
                ],
                "spaceLength": 10,
                "span": 6,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "histogram_quantile(0.99, sum(rate(coredns_dns_response_size_bytes_bucket{instance=~\"$instance\",proto=\"udp\"}[5m])) by (le,proto)) ",
                    "intervalFactor": 2,
                    "legendFormat": "{{proto}}:99%",
                    "refId": "A",
                    "step": 40
                  },
                  {
                    "expr": "histogram_quantile(0.90, sum(rate(coredns_dns_response_size_bytes_bucket{instance=\"$instance\",proto=\"udp\"}[5m])) by (le,proto)) ",
                    "intervalFactor": 2,
                    "legendFormat": "{{proto}}:90%",
                    "refId": "B",
                    "step": 40
                  },
                  {
                    "expr": "histogram_quantile(0.50, sum(rate(coredns_dns_response_size_bytes_bucket{instance=~\"$instance\",proto=\"udp\"}[5m])) by (le,proto)) ",
                    "intervalFactor": 2,
                    "legendFormat": "{{proto}}:50%",
                    "metric": "",
                    "refId": "C",
                    "step": 40
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Responses (size, udp)",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "cumulative"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "bytes",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  },
                  {
                    "format": "short",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  }
                ]
              },
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "${DS_PROMETHEUS}",
                "editable": true,
                "error": false,
                "fill": 1,
                "grid": {},
                "id": 13,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 2,
                "links": [],
                "nullPointMode": "connected",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [
                  {
                    "alias": "udp:50%",
                    "yaxis": 1
                  },
                  {
                    "alias": "tcp:50%",
                    "yaxis": 1
                  },
                  {
                    "alias": "tcp:90%",
                    "yaxis": 1
                  },
                  {
                    "alias": "tcp:99%",
                    "yaxis": 1
                  }
                ],
                "spaceLength": 10,
                "span": 6,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "histogram_quantile(0.99, sum(rate(coredns_dns_response_size_bytes_bucket{instance=~\"$instance\",proto=\"tcp\"}[5m])) by (le,proto)) ",
                    "intervalFactor": 2,
                    "legendFormat": "{{proto}}:99%",
                    "refId": "A",
                    "step": 40
                  },
                  {
                    "expr": "histogram_quantile(0.90, sum(rate(coredns_dns_response_size_bytes_bucket{instance=~\"$instance\",proto=\"tcp\"}[5m])) by (le,proto)) ",
                    "intervalFactor": 2,
                    "legendFormat": "{{proto}}:90%",
                    "refId": "B",
                    "step": 40
                  },
                  {
                    "expr": "histogram_quantile(0.50, sum(rate(coredns_dns_response_size_bytes_bucket{instance=~\"$instance\",proto=\"tcp\"}[5m])) by (le, proto)) ",
                    "intervalFactor": 2,
                    "legendFormat": "{{proto}}:50%",
                    "metric": "",
                    "refId": "C",
                    "step": 40
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Responses (size, tcp)",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "cumulative"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "bytes",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  },
                  {
                    "format": "short",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  }
                ]
              }
            ],
            "repeat": null,
            "repeatIteration": null,
            "repeatRowId": null,
            "showTitle": false,
            "title": "New row",
            "titleSize": "h6"
          },
          {
            "collapse": false,
            "height": "250px",
            "panels": [
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "${DS_PROMETHEUS}",
                "editable": true,
                "error": false,
                "fill": 1,
                "grid": {},
                "id": 15,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 2,
                "links": [],
                "nullPointMode": "connected",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [],
                "spaceLength": 10,
                "span": 6,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "sum(coredns_cache_size{instance=~\"$instance\"}) by (type)",
                    "intervalFactor": 2,
                    "legendFormat": "{{type}}",
                    "refId": "A",
                    "step": 40
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Cache (size)",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "cumulative"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "short",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  },
                  {
                    "format": "short",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  }
                ]
              },
              {
                "aliasColors": {},
                "bars": false,
                "dashLength": 10,
                "dashes": false,
                "datasource": "${DS_PROMETHEUS}",
                "editable": true,
                "error": false,
                "fill": 1,
                "grid": {},
                "id": 16,
                "legend": {
                  "avg": false,
                  "current": false,
                  "max": false,
                  "min": false,
                  "show": true,
                  "total": false,
                  "values": false
                },
                "lines": true,
                "linewidth": 2,
                "links": [],
                "nullPointMode": "connected",
                "percentage": false,
                "pointradius": 5,
                "points": false,
                "renderer": "flot",
                "seriesOverrides": [
                  {
                    "alias": "misses",
                    "yaxis": 2
                  }
                ],
                "spaceLength": 10,
                "span": 6,
                "stack": false,
                "steppedLine": false,
                "targets": [
                  {
                    "expr": "sum(rate(coredns_cache_hits_total{instance=~\"$instance\"}[5m])) by (type)",
                    "intervalFactor": 2,
                    "legendFormat": "hits:{{type}}",
                    "refId": "A",
                    "step": 40
                  },
                  {
                    "expr": "sum(rate(coredns_cache_misses_total{instance=~\"$instance\"}[5m])) by (type)",
                    "intervalFactor": 2,
                    "legendFormat": "misses",
                    "refId": "B",
                    "step": 40
                  }
                ],
                "thresholds": [],
                "timeFrom": null,
                "timeShift": null,
                "title": "Cache (hitrate)",
                "tooltip": {
                  "shared": true,
                  "sort": 0,
                  "value_type": "cumulative"
                },
                "type": "graph",
                "xaxis": {
                  "buckets": null,
                  "mode": "time",
                  "name": null,
                  "show": true,
                  "values": []
                },
                "yaxes": [
                  {
                    "format": "pps",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  },
                  {
                    "format": "pps",
                    "logBase": 1,
                    "max": null,
                    "min": 0,
                    "show": true
                  }
                ]
              }
            ],
            "repeat": null,
            "repeatIteration": null,
            "repeatRowId": null,
            "showTitle": false,
            "title": "New row",
            "titleSize": "h6"
          }
        ],
        "schemaVersion": 14,
        "style": "dark",
        "tags": [
          "dns",
          "coredns"
        ],
        "templating": {
          "list": [
            {
                "current": {
                    "text": "Prometheus",
                    "value": "Prometheus"
                },
                "hide": 0,
                "label": null,
                "name": "DS_PROMETHEUS",
                "options": [

                ],
                "query": "prometheus",
                "refresh": 1,
                "regex": "",
                "type": "datasource"
            },
            {
              "allValue": ".*",
              "current": {},
              "datasource": "${DS_PROMETHEUS}",
              "hide": 0,
              "includeAll": true,
              "label": "Instance",
              "multi": false,
              "name": "instance",
              "options": [],
              "query": "up{job=\"coredns\"}",
              "refresh": 1,
              "regex": ".*instance=\"(.*?)\".*",
              "sort": 0,
              "tagValuesQuery": "",
              "tags": [],
              "tagsQuery": "",
              "type": "query",
              "useTags": false
            }
          ]
        },
        "time": {
          "from": "now-3h",
          "to": "now"
        },
        "timepicker": {
          "now": true,
          "refresh_intervals": [
            "5s",
            "10s",
            "30s",
            "1m",
            "5m",
            "15m",
            "30m",
            "1h",
            "2h",
            "1d"
          ],
          "time_options": [
            "5m",
            "15m",
            "1h",
            "6h",
            "12h",
            "24h",
            "2d",
            "7d",
            "30d"
          ]
        },
        "timezone": "utc",
        "title": "CoreDNS",
        "version": 3,
        "description": "A dashboard for the CoreDNS DNS server."
      }