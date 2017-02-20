This tutorial is going to explore a few ways to improve
[Elasticsearch][Elasticsearch] performance.

To have a working example -- and to make things more interesting -- we're going
to graph Bitcoin's exchange rate on [Bitstamp][bitstamp].

<div style="text-align:center">
![End Result]({{site.url}}/images/elk-tuning-nifi-btc-08-timelion.png)
</div>

To make this happen, we're going to use :

* [Bitstamp][bitstamp], which offers a public API which lets us query the current
  exchange rate
* [Apache NiFi][nifi], which is an ETL of sorts : it can pull data from a
  source, transform it, and inject it somewhere else, defining complex
  pipelines where needed. We'll use it to pull the Bitcoin exchange rate from
  [Bitstamp][bitstamp]
* [Elasticsearch][elasticsearch], which is a powerful and popular indexing
  software. It can be used as a NoSQL document store and we're going to use it
  to store the Bitcoin exchange rate as a time series
* [Timelion][timelion], which is a [Kibana][kibana] plugin designed to make
  sense of, and analyze, time series

----

* This will become a table of contents (this text will be scraped).
{:toc}
