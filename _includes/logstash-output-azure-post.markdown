## Introduction

Logstash is an open source data collection engine with real-time pipelining capabilities. Logstash can dynamically unify data from disparate sources and normalize the data into destinations of your choice. Cleanse and democratize all your data for diverse advanced downstream analytics and visualization use cases. (Source)

<iframe width="727" height="154" src="https://www.souravbadami.me/blog/wp-content/uploads/2017/02/Screenshot-from-2017-02-24-100912.png" frameborder="0" allowfullscreen></iframe>

## What is meant by an output plugin ?

We already know from the above introduction that Logstash could be used to collect data from different sources. These collections are done through some input sources with the help of an input plugin. So, for these data to move out to a required source from Logstash engine — We need an output plugin.

## What is Logstash -> Azure Event Hub output plugin ?

Logstash -> Azure Event Hub output plugin is a Logstash output plugin written using NodeJS.

Working: The NodeJS script listens to a predefined port (it depends on the user) and accepts the data via an http response in json format. It then pushes the data to the azure event hub using the send method from the azure-event-hubs NodeJS api.

We are working on the native plugin for logstash which could push the data directly to the azure event hub, but this might work as a temporary solution for now.