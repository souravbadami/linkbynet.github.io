# Setting up NiFi

[NiFi][nifi] works by fetching data from its source into a so called
"Flowfile" and then letting the flowfile go through Processors. Each processor
will in turn extract or modify data from the flowfile and then pass it on to
the next one.  This will go on until the flowfile has been through the entire
workflow you defined.

## Installation

Fetching the [NiFi][nifi] distribution, unpacking and starting it is best
described in the [official documentation][nifi-install] so we will not cover
this here.

## Assembling the Processors

We are going to use 4 processors for this little project :

* [GetHTTP][gethttp] will connect to the [Bitstamp][bitstamp] API endpoint to get the
  current exchange rate and volume
* [JoltJSONTransform][jolt] will be used to retain only the information we are
  interested in, and to get rid of the rest
* [EvaluateJSONPath][jsonpath] will let us fetch the timestamp from within the Flowfile
  and save it as a Flowfile attribute for later use
* [PutElasticsearch5][es5] will finally index the Flowfile into Elasticsearch using
  the timestamp Flowfile attribute to specify which index to put it into

Let's get into the details of each Processor.

<div class="note info">
##### Info
You will have to connect to the [NiFi webinterface][nifi-webgui] (default URL
when installed locally).
</div>

[nifi-webgui]: http://localhost:8080/nifi

### Defining an SSL Context Service

We are going to connect to an HTTPs website in order to collect the Bitcoin
trading information, and as such we need to setup a
`StandardSSLContextService`. This will provide root certificates for example.

You can do this in [NiFi][nifi] as showed in the following animation :

![NiFi's SSL configuration]({{ site.url}}/images/elk-tuning-nifi-btc-10-ssl.gif)

|-----------+---------------------|-----------------------------------------------|
|Tab        | Property            | Value                                         |
|:----------+:--------------------|:----------------------------------------------|
|Settings   | Name                | StandardSSLContextService                     |
|-----------+---------------------+-----------------------------------------------|
|Properties | Truststore Filename | /opt/jre/lib/security/cacerts                 |
|-----------+---------------------+-----------------------------------------------|
|Properties | Truststore Password | changeit                                      |
|-----------+---------------------+-----------------------------------------------|

Those settings are those of the default Java Runtime Environment Truststore.
You might have to adjust both the path and the password to match your
installation.

### Positioning the necessary Processors

The following animation will demonstrate how to position the Processors and
link them together to compose our workflow :

![Processors]({{ site.url}}/images/elk-tuning-nifi-btc-01-processors.gif)

Once this is done, it will be time to configure each Processor.

### GetHTTP Processor

The [GetHTTP][gethttp] Processor is used to download a single webpage. In our
case, it will be used to fetch the Bitcoin trading information as a JSON
formatted file from [Bitstamp][bitstamp] API.

If you would query it in a web browser, this is what you would see :
![GetHTTP]({{ site.url}}/images/elk-tuning-nifi-btc-07-bitstampjsonapi.png)

We are basically going to have [NiFi][nifi] do the same through the
[GetHTTP processor][gethttp].

As you might expect, we need to configure a few settings :

|-----------+---------------------|-----------------------------------------------|
|Tab        | Property            | Value                                         |
|:----------+:--------------------|:----------------------------------------------|
|Properties |URL                  | https://www.bitstamp.net/api/v2/ticker/btcusd/|
|-----------+---------------------+-----------------------------------------------|
|Properties |Filename             | btcusd.json                                   |
|-----------+---------------------+-----------------------------------------------|
|Properties |SSL Context Service  | StandardSSLContextService                     |
|-----------+---------------------+-----------------------------------------------|
|Scheduling |Run schedule         | 60 sec                                        |
|-----------+---------------------+-----------------------------------------------|

Here's the demo illustrating how to configure this all :

![GetHTTP]({{ site.url}}/images/elk-tuning-nifi-btc-02-set-GetHTTP.gif)

### JoltTransformJSON Processor

Next, we're going to configure the [JoltTransformJSON][jolt] processor.

Jolt is to JSON what XSLT is to XML. It lets you describe in JSON how to
transform an input JSON document into an output JSON document.

We're going to use this mechanism to keep only what we are interested in from the JSON document we get from
the [Bitstamp][bitstamp] API.

Here are the settings to configure :

|-----------+------------------------|-----------------------------------------------|
|Tab        | Property               | Value                                         |
|:----------+:-----------------------|:----------------------------------------------|
|Properties |Jolt Transformation DSL | Shift                                         |
|-----------+------------------------+-----------------------------------------------|
|Properties |Jolt Specification      | See below                                     |
|-----------+------------------------+-----------------------------------------------|

The Jolt specification is the JSON document where we basically describe that
we will map the `timestamp`, `volume` and `last` fields from the input into
the same fields in the output. This will implicitly discard the other fields.

Here is what it looks like :

{% highlight json %}
{
  "timestamp" : "timestamp",
  "last" : "last",
  "volume" : "volume"
}
{% endhighlight %}


![JOLT]({{ site.url}}/images/elk-tuning-nifi-btc-03-setJolt.gif)

<div class="note protip no_toc">
##### Protip!

Elasticsearch indexes can grow really big really quickly. This means they will
require more resources to store (disk space) and process (CPU, RAM).

**Always index as little as possible to satisfy your business needs.**
</div>

### EvaluateJsonPath Processor

There will be an Elasticsearch index for each day, so we need to extract the
timestamp from the JSON data returned by [Bitstamp][bitstamp] and set it as a
Flowfile attribute so that we can later use it to define the index we want to
insert the data into.

We're going to use the [EvaluateJsonPath Processor][jsonpath] to do this, by
configuring it as show in the table below :

|-----------+-------------+-------------------------|
|Tab        | Property    | Value                   |
|:----------+:------------+:------------------------|
|Properties |Destination  | flowfile-attribute      |
|-----------+-------------+-------------------------|
|Properties |timestamp    | $.timestamp             |
|-----------+-------------+-------------------------|

![EvalJSON]({{ site.url}}/images/elk-tuning-nifi-btc-04-setEvalJSON.gif)

### PutElasticsearch5 Processor

Finally, the Flowfile processing will end with it being indexed into
Elasticsearch, which will be performed by the PutElasticsearch5 Processor.

Here are the settings to configure :

|-----------+------------------------|-----------------------------------------------------------|
|Tab        | Property               | Value                                                     |
|:----------+:-----------------------|:----------------------------------------------------------|
|Properties |Cluster name            | Elasticsearch                                             |
|-----------+------------------------+-----------------------------------------------------------|
|Properties |ElasticSearch Hosts     | 127.0.0.1:9300                                            |
|-----------+------------------------+-----------------------------------------------------------|
|Properties |Identifier Attribute    | uuid                                                      |
|-----------+------------------------+-----------------------------------------------------------|
|Properties |Index                   | bitstamp-${timestamp:multiply(1000):format("yyyy-MM-dd")} |
|-----------+------------------------+-----------------------------------------------------------|
|Properties |Type                    | bitstampquotes                                            |
|-----------+------------------------+-----------------------------------------------------------|
|Properties |Batch Size              | 100                                                       |
|-----------+------------------------+-----------------------------------------------------------|

Worth noting : 

* We set the Index to have a name containing the day of the data, so as to be
able to drop entire indexes when purging old data
* The `Type` name has to match whatever you had configured in your index
  template so as to get mapped to the proper parameters
* The `Batch Size` parameter is left to it's default value in this toy project
  of ours, however it is one to test for and tune appropriately. It controls
  how many documents [NiFi][nifi] will pool before sending a bulk indexing request
  to [Elasticsearch][elasticsearch]

![PutES5]({{ site.url}}/images/elk-tuning-nifi-btc-05-setPutES5.gif)

<div class="note protip no_toc">
##### Protip!

Use Elasticsearch's bulk API whenever possible : It will have Elasticsearch
process multiple documents at once and improve significantly performance by
reducing the query overhead per document.
</div>


## Checking the flow behavior

Once this is all in place and configured, we can the Processors one by one and
check that it behaves as intended :

![Check]({{ site.url}}/images/elk-tuning-nifi-btc-06-check.gif)


