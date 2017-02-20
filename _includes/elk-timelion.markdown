# Timelion

[Timelion][timelion] is a [Kibana][kibana] plugin which allows you to analyze
time series.

It let you plot and compare different datasources on different timeframes (ex :
website traffic this week compared to last week), compute statistical
functions like derivatives and sliding window averages, and many other things.

The following video does a better job than I could at showing what you can expect from
[Timelion][timelion], so I suggest watching it to get a better
idea of what you can do :
<iframe width="560" height="315" src="https://www.youtube.com/embed/L5LvP_Cj0A0" frameborder="0" allowfullscreen></iframe>

In our case, we simply want to graph the Bitcoin exchange rate and the trading
volume over time :

{% highlight text %}
.es(index="bitstamp*", timefield="timestamp", metric="avg:last").fit(carry).movingaverage(window=10)
.es(index="bitstamp*",timefield="timestamp",metric="avg:volume").fit(carry).yaxis(2)
{% endhighlight %}

Let's go through the first line :

1. `.es()` : We use the datasource Elasticsearch (`.es`) and pull the data from the
   indices matching `bitstamp*`
1. The field holding the time component of the time series is `timestamp`
1. We want to plot the average of the `last` field (this is the last exchange
   rate)
1. `fit(carry)` : if there is no data available when required for a
   computation, then we'll just use the last one available
1. `movingaverage(window=10)` : finally we'll plot the moving average over the
   last 10 values

The plotting of the volume is very similar.

This will result in the following graph :

![Final result]({{site.url}}/images/elk-tuning-nifi-btc-09-timelion.png)
