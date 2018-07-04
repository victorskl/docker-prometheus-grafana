# docker-prometheus-grafana

Docker compose stack for Prometheus + Grafana monitoring.

```
cp env.sample .env
cp prometheus.yml.sample prometheus.yml

mkdir -p ./data/prometheus
mkdir -p ./data/grafana

chown -R nobody:nogroup ./data/prometheus
chown -R 472 ./data/grafana

docker-compose -p dev up -d
docker-compose -p dev down
```


## Quick Walk-through

- Both Prometheus and Grafana data are persisted into `./data`.

- The `env.sample` contains Grafana configuration as environment variables. Refer Grafana [configuration documentation](http://docs.grafana.org/installation/configuration/) for more options.

- Work out [Prometheus configuration](https://prometheus.io/docs/prometheus/latest/configuration/configuration/) from the sample file `prometheus.yml.sample` for scraping metrics. This sample config scrape Grafana and Prometheus metrics to start with. 

- If new to Prometheus, the [First steps with Prometheus](https://prometheus.io/docs/introduction/first_steps/) is a good 101 intro article.

- Both [Grafana Support For Prometheus](https://prometheus.io/docs/visualization/grafana/) and [Using Prometheus in Grafana](http://docs.grafana.org/features/datasources/prometheus/) articles contain quick start from the perspective of either side. However, this stack has already used the [Grafana Provisioning](http://docs.grafana.org/administration/provisioning/) feature and, has done provisioning configuration with the Prometheus datasource.


- The stack metrics are available at:
  - Prometheus - [http://localhost:9090/metrics](http://localhost:9090/metrics)
  - Grafana - [http://localhost:3000/metrics](http://localhost:3000/metrics)
  - cAdvisor - [http://localhost:4194/metrics](http://localhost:4194/metrics)

### Prometheus

- Prometheus default dashboard available at: [http://localhost:9090](http://localhost:9090)

- Go to [http://localhost:9090/targets](http://localhost:9090/targets) and make sure [all targets are __UP__](assets/prometheus_targets.png). These targets are jobs from [prometheus.yml](prometheus.yml.sample) configuration.

- Go to [http://localhost:9090/graph](http://localhost:9090/graph) and add the follow Prom query in __Expression__ input box. Switch to __Graph__ tab to observe the memory usage of containers that fall under __dev__ project namespace (i.e `-p dev` bit).

  ```
  container_memory_usage_bytes{container_label_com_docker_compose_project ="dev"}
  ```

- Prometheus exporters - [https://prometheus.io/docs/instrumenting/exporters/](https://prometheus.io/docs/instrumenting/exporters/)


### Grafana

- Grafana dashboard at: [http://localhost:3000](http://localhost:3000). Login with `admin:admin` unless you have modified in your `.env` file.

- Then goto [http://localhost:3000/datasources](http://localhost:3000/datasources) > click __Prometheus__ > __Dashboards__ tab > import the built-in dashboards

- If you would like to load any preconfigured datasources, add them in [`grafana/provisioning/datasources`](grafana/provisioning/datasources).

- If you would like to load any preconfigured dashboards, add them in [`dashboards`](dashboards) directory.

- More Grafana dashboards at: [https://grafana.com/dashboards?dataSource=prometheus](https://grafana.com/dashboards?dataSource=prometheus)


### Exporting Metrics

To monitor nodes and containers within a cluster, go to each node, run cAdvisor to export containers metrics, run node_exporter to export machine metrics, and add each host in `scrape_configs` as a job using hostname e.g.
  
  ```
  - job_name: 'cadvisor'
    scrape_interval: 10s
    metrics_path: '/metrics'
    static_configs:
     - targets: ['PUBLIC_IP:4194','DOMAIN_NAME:4194','HOST:4194','node1:4194','node2:4194']

  - job_name: 'node_exporter'
    scrape_interval: 10s
    metrics_path: '/metrics'
    static_configs:
     - targets: ['PUBLIC_IP:9100','DOMAIN_NAME:9100','HOST:9100','node1:9100','node2:9100']
  ```



#### cAdvisor

- cAdvisor is used for containers monitoring.

- cAdvisor default dashboard available at: [http://localhost:4194](http://localhost:4194) which show the root container.

- For sub-containers (i.e those that deployed) are available at: [http://localhost:4194/docker](http://localhost:4194/docker)

- cAdvisor export these containers metrics at: [http://localhost:4194/metrics](http://localhost:4194/metrics) in Prometheus format.

- To add Grafana dashboard for monitoring containers, go to [http://localhost:3000/dashboard/import](http://localhost:3000/dashboard/import) and add __193__ in dashboard ID input box and press __Load__ button. This will install dashboard ID [__193__ - Docker monitoring](https://grafana.com/dashboards/193) which visualize cAdvisor exported container metrics. Another good candidate is dashboard ID [__179__](https://grafana.com/dashboards/179).

- To export containers metrics on each node within a cluster, run cAdvisor on each node:
  ```
  docker-compose -f cadvisor.yml -p dev up -d
  ```

#### node_exporter

- To monitor the host node, use [node_exporter](https://github.com/prometheus/node_exporter).
 
- Running _node_exporter_ as a container [is not recommended](https://github.com/prometheus/node_exporter#using-docker). Therefore, use distribution package or run it someway through [`systemd` service](https://github.com/prometheus/node_exporter/tree/master/examples).
  ```
  apt install prometheus-node-exporter
  systemctl status prometheus-node-exporter
  ```
  Or install the latest [node_exporter](node_exporter) using Ansible:
  ```
  cd node_exporter
  cp hosts.ini.sample hosts.ini
  bash setup.sh ubuntu ~/.ssh/id_rsa node_exporter.yml
  ```

- At any case, `node_exporter` exports machine metrics at: [http://localhost:9100/metrics](http://localhost:9100/metrics)

- Uncomment `node_exporter` job in [prometheus.yml](prometheus.yml.sample) to start scraping node metrics.

- Go to [http://localhost:9090/graph](http://localhost:9090/graph) and at _Expression_ input box, enter `node_cpu_seconds_total` to observe _node_exporter_ metrics.

- A good starting point for [`node_exporter` collector](https://grafana.com/dashboards?collector=nodeExporter) based Grafana dashboards are [__22__](https://grafana.com/dashboards/22), [__405__](https://grafana.com/dashboards/405), [__893__](https://grafana.com/dashboards/893). Note that some of these dashboards are outdated and, may need to tune to fit with [latest version of _node_exporter_ metrics](https://github.com/prometheus/node_exporter/releases/tag/v0.16.0), e.g. 

  ```
  node_cpu >> node_cpu_seconds_total
  node_boot_time >> node_boot_time_seconds
  label_values(node_boot_time, instance) >> label_values(node_boot_time_seconds, instance)
  ```

#### Micrometer

- To export Spring Boot application metrics, use [Micrometer Prometheus](http://micrometer.io/docs/registry/prometheus). It just need to add dependency. _The [micrometer-jvm-extras](https://github.com/mweirauch/micrometer-jvm-extras) is optional_. This expose metrics at [http://localhost:8080/prometheus](http://localhost:8080/prometheus).

  ```
  <dependency>
    <groupId>io.micrometer</groupId>
    <artifactId>micrometer-registry-prometheus</artifactId>
    <version>1.0.3</version>
  </dependency>
  
  <dependency>
      <groupId>io.github.mweirauch</groupId>
      <artifactId>micrometer-jvm-extras</artifactId>
      <version>0.1.2</version>
  </dependency>
  ```

- Uncomment `spring-boot-restful` job in [prometheus.yml](prometheus.yml.sample) to start scraping spring boot app default metrics such as JVM, Tomcat, etc.

- A good starter Grafana dashboard is ID [__4701__](https://grafana.com/dashboards/4701).




---

Similar stacks

- https://github.com/vegasbrianc/prometheus
- https://github.com/stefanprodan/dockprom

