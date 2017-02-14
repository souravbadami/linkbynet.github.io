# Indexes configuration and Data modeling

## Shards and replicas

Indexes are divided in shards, and shards have replicas. Both shards and
replicas will be distributed over the different nodes of an Elasticsearch
cluster :

* The number of shards conditions the capacity of the cluster to distribute
  write operations over different nodes. Too few means that after a point,
  adding nodes will not improve writing performance. Too many will waste RAM.
* The number of replicas condition the capacity of the cluster to distribute
  the read operations, as well as the fault tolerance. Too many will consume
  disk space. Too few will impact read performance and fault tolerance.

The settings of the indexes are critical to Elasticsearch performance.

<div class="note protip">
##### Protip!

When it comes to shards and replicas, it's a bit of a [Goldilocks
principle](https://en.wikipedia.org/wiki/Goldilocks_principle) in action : Not
too many, not to few, just enough.

Choose the numbers of shards and replicas of the indexes wisely because you
cannot change them afterwards (you will need to reindex the data).
</div>

## Field mappings

Indexation, queries and aggregations can be costly in CPU and RAM resources but
you can use your knowledge of the data you will store and help Elasticsearch do
a better job.

For example :

* if you know that you won't be searching in specific fields of your documents,
  you can instruct Elasticsearch not to index them
* if you won't be sorting or aggregating, leave fielddata disabled
* If you know that a numeric field will be within a certain range, you can choose the smallest numeric type
* ...

## Putting it all together

Both the shards / replicas settings and the field mappings can be set in an
index template.

Here is the one we will use for our little Bitcoin indexing experiment, which
we will save in the `bitstamp-template.json` file :

{% highlight json %}
{
        "template" : "bitstamp-*",
        "settings": {
                "number_of_shards" : 5,
                "number_of_replicas" : 0
        },
        "mappings" : {
                "_default_" : {
                        "properties" : {
                                "timestamp" : {
                                        "type" : "date",
                                        "format" : "epoch_second"
                                }
                        }
                },
                "bitstampquotes": {
                        "properties" : {
                                "last" : {
                                        "type" : "scaled_float",
                                        "scaling_factor" : 100,
                                        "index" : false,
                                        "coerce" : true
                                },
                                "volume" : {
                                        "type" : "float",
                                        "index" : false,
                                        "coerce" : true
                                }
                        }
                }
        }
}
{% endhighlight %}

In this somewhat trivial template, we do the following : 

* We instruct Elasticsearch to apply it to any index which name starts with
"bitstamp-" 
* We fix the number of shards (which is actually the default, and to be honest
we could have set it to 1 for this pet project) and the number of replica to
zero because we will be in a single node "cluster".
* We indicate that the `timestamp` field is a date field, and will be provided
in a number of seconds since January, 1st, 1970.
* The `last` field is a currency with 2 decimal places, so we set it as a
`scaled_float` with a factor of 100 (which is like saying that the `last` rate
will be internally stored by Elasticsearch as the number of cents and showed
after dividing it by 100)
* We are never going to search for an indexed document by `last` rate or
`volume` so we instruct Elasticsearch not to bother indexing it

You can put this index template in place with the following command :
{% highlight bash %}
curl -XPUT http://localhost:9200/_template/bitstamp_template_1?pretty -d @bitstamp-template.json
{% endhighlight%}

<div class="note protip">
##### Protip!

Use your knowledge of the data you will store into Elasticsearch to guide it
into being more efficient and consume less resources.
</div>
