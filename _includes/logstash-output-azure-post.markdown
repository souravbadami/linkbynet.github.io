## Introduction

We needed to transfer logs and other data from Logstash to Microsoft Azure Event Hub. There are several available output plugins to ship the data from Logstash directly to several destinations like, csv, boundary, circonus, cloudwatch and many [more][output-plugins]. There’s no available plugin to ship data directly to Azure’s Event Hub.

Logstash is an open source data collection engine with real-time pipelining capabilities. Logstash can dynamically unify data from disparate sources and normalize the data into destinations of your choice. Cleanse and democratize all your data for diverse advanced downstream analytics and visualization use cases. ([Source][logstash])

Event Hubs is a highly scalable data streaming platform capable of ingesting millions of events per second. Data sent to an Event Hub can be transformed and stored using any real-time analytics provider or batching/storage adapters. With the ability to provide publish-subscribe capabilities with low latency and at massive scale, Event Hubs serves as the “on ramp” for Big Data. ([Source][eventhub])

Although we didn’t find anything to ship data directly from Logstash to Azure Event Hub, we found that there is an existing plugin which gives output to an HTTP or HTTPS endpoint. So, we tried to use the [logstash-output-http][logstash-output-http] plugin to forward the events to a NodeJS tool and then use the Azure NodeJS API to push them to the Event Hub, as seen below :

![GetHTTP]({{ site.url}}/images/logstash-azure-nodejs-flow.png)

Now, you might think — why didn’t we  write a native plugin ? It would seem like the easiest thing to use with Logstash. Well, we didn’t find any available Ruby API for Azure and Logstash plugins are written using Ruby. We also know that Logstash is written using jRuby and there’s an available Java API for the Hub. So, we can use a jar injection in Ruby to design a native plugin.


You can find the source of our solution [here][source]. Just replace the Event Hub connection string and desired http output port in config.js and execute the script.

We are working on the native plugin for logstash which could push the data directly to the azure event hub, but this might work as a temporary solution for now.

[logstash]: https://www.elastic.co/guide/en/logstash/current/introduction.html
[eventhub]: https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-what-is-event-hubs
[output-plugins]: https://www.elastic.co/guide/en/logstash/current/output-plugins.html
[logstash-output-http]: https://github.com/logstash-plugins/logstash-output-http
[source]: https://github.com/linkbynet/OPS2.0/tree/master/lemur
