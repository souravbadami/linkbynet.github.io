---
layout: post
title:  "Elasticsearch tuning : a simple use case exploring ELK,  NiFi and Bitcoin"
date:   2017-02-07 15:40:56
author: skattoor

categories: Elasticsearch tuning
---
{::options parse_block_html="true" /}

{% include elk-intro.markdown %}

{% include elk-elk.markdown %}

{% include elk-datamodeling.markdown %}

{% include elk-nifi.markdown %}

{% include elk-timelion.markdown %}

{% include elk-conclusion.markdown %}

# References

## Software stack

* [Bitstamp][bitstamp]
* [Elasticsearch][es5]
* [Timelion][timelion]
* [Kibana][kibana]
* [Curator][curator]
* [Apache NiFi][nifi]

## Elasticsearch reference material

* [Elasticsearch installation procedure][elastic-install]
* [Kibana installation procedure][kibana-install]
* [Elasticsearch performance tuning][es-performance]
* [Elasticsearch performance tuning for indexing speed][es-perf-tuning]
* [Elasticsearch system configuration][es-system-tuning]

## NiFi reference material

* [GetHTTP Processor][gethttp]
* [JoltTransformJSON Processor][jolt]
* [EvaluateJsonPath Processor][jsonpath]
* [PutElasticsearch5 Processor][es5]


[elastic]: https://www.elastic.co/
[elastic-install]: https://www.elastic.co/guide/en/elasticsearch/reference/current/_installation.html
[kibana-install]: https://www.elastic.co/guide/en/kibana/current/setup.html
[bitstamp]: https://www.bitstamp.net
[elasticsearch]: https://www.elastic.co/products/elasticsearch
[nifi]: https://nifi.apache.org/
[timelion]: https://www.elastic.co/blog/timelion-timeline
[kibana]: https://www.elastic.co/products/kibana
[nifi-install]: https://nifi.apache.org/docs/nifi-docs/html/getting-started.html#downloading-and-installing-nifi
[curator]: https://www.elastic.co/guide/en/elasticsearch/client/curator/current/index.html
[curator-example]: https://www.elastic.co/guide/en/elasticsearch/client/curator/current/ex_delete_indices.html
[curator-config]: https://www.elastic.co/guide/en/elasticsearch/client/curator/current/configfile.html

[gethttp]: https://nifi.apache.org/docs/nifi-docs/components/org.apache.nifi.processors.standard.GetHTTP/
[jolt]: https://nifi.apache.org/docs/nifi-docs/components/org.apache.nifi.processors.standard.JoltTransformJSON/
[jsonpath]: https://nifi.apache.org/docs/nifi-docs/components/org.apache.nifi.processors.standard.EvaluateJsonPath/ 
[es5]: https://nifi.apache.org/docs/nifi-docs/components/org.apache.nifi.processors.elasticsearch.PutElasticsearch5/index.html
[es-performance]: https://www.elastic.co/guide/en/elasticsearch/guide/current/indexing-performance.html
[es-perf-tuning]: https://www.elastic.co/guide/en/elasticsearch/reference/master/tune-for-indexing-speed.html
[es-system-tuning]: https://www.elastic.co/guide/en/elasticsearch/reference/current/system-config.html
