# Timelion

[Timelion][timelion] is a [Kibana][kibana] plugin which let's you analyze
timeseries.

It let's you plot, compare different datasources on different timeframes (ex :
website traffic this week compared to last week), compute statistical
functions like derivatives and sliding window averages, and many other things.

The following video does a better job at showing what you can expect from
[Timelion][timelion] than I could, so I suggest you watch it to get a better
idea of what you can do :
<iframe width="560" height="315" src="https://www.youtube.com/embed/L5LvP_Cj0A0" frameborder="0" allowfullscreen></iframe>

In our case, we simply want to graph the Bitcoin exchange rate and the trading
volume over time :

{% highlight text %}
.es(index="bitstamp*", timefield="timestamp", metric="avg:last").fit(carry).movingaverage(window=10)
.es(index="bitstamp*",timefield="timestamp",metric="avg:volume").fit(carry).yaxis(2)
{% endhighlight %}

The first line describes the 
