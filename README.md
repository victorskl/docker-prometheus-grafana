# docker-prometheus-grafana

Docker compose stack for Prometheus + Grafana monitoring.

```
cp env.sample .env
cp prometheus.yml.sample prometheus.yml

mkdir -p ./data/prometheus
mkdir -p ./data/grafana

docker-compose -p dev up -d
docker-compose -p dev down
```

---

Prometheus

- https://hub.docker.com/r/prom/prometheus/
- https://prometheus.io/docs/prometheus/latest/installation/

Grafana

- https://hub.docker.com/r/grafana/grafana/
- http://docs.grafana.org/installation/docker/

## quick walk-through

- Both Prometheus and Grafana data are persisted into `./data`.

- The `env.sample` contains Grafana configuration as environment variables. Refer Grafana [configuration documentation](http://docs.grafana.org/installation/configuration/) for more options.

- Work out [Prometheus configuration](https://prometheus.io/docs/prometheus/latest/configuration/configuration/) from the sample file `prometheus.yml.sample` for scraping metrics. This sample config scrape Grafana and Prometheus metrics to start with. 

- If new to Prometheus, the [First steps with Prometheus](https://prometheus.io/docs/introduction/first_steps/) is a good 101 intro article.

- Both [Grafana Support For Prometheus](https://prometheus.io/docs/visualization/grafana/) and [Using Prometheus in Grafana](http://docs.grafana.org/features/datasources/prometheus/) articles contain quick start from the perspective of either side. However, it has already used the [Grafana Provisioning](http://docs.grafana.org/administration/provisioning/) feature and, has done configuration with the Prometheus datasource.

- Prometheus: [http://localhost:9090](http://localhost:9090)

- Grafana: [http://localhost:3000](http://localhost:3000). Login with `admin:admin` unless you have modified in your `.env` file.

- Then goto [http://localhost:3000/datasources](http://localhost:3000/datasources) > click __Prometheus__ > __Dashboards__ tab > import the built-in dashboards

- If you would like to load any preconfigured datasources, add them in [`grafana/provisioning/datasources`](grafana/provisioning/datasources).

- If you would like to load any preconfigured dashboards, add them in [`dashboards`](dashboards) directory.

- Prometheus exporters - https://prometheus.io/docs/instrumenting/exporters/


- Grafana dashboards - https://grafana.com/dashboards?dataSource=prometheus


