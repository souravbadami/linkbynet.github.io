# Configuring Elasticsearch

## System / hardware

Elasticsearch is a resource hungry beast! You will need :

* *(Very) Fast disks* : Preferably SSDs, preferably in RAID-0 for maximum I/O
performance (or you can have multiple disks mounted on your system and let
Elasticsearch decide where to write). This is assuming that you will have an
Elasticsearch cluster with data redundancy.
* *Lots of RAM* : Ample amounts of RAM will be required to run complex queries. It
is however recommended to allocate half of the system memory to Elasticsearch,
and leave the remaining half to the system for disk caching
* *Enough CPU power* : Indexing and searching can mean going through a lot of data, and
you will obviously get better response times with faster CPU. Although
Elasticsearch is probably less greedy for CPU than it is for Disk speed or RAM
quantity.

Correctly sizing an Elasticsearch cluster is generally a difficult task and
it requires experience to do it right.

Identify your functional requirements: 

* how much data you are going to ingest,
* what type of queries you are going to run,
* what query response times you want to achieve, 
* etc.

Then test for performance during the early phases of your project: This will
allow you to have metrics to correctly size your production platform.

Start with a small platform and make it grow to address your functional
requirements.

The beauty of Elasticsearch is that you can grow your cluster very easily by
adding more nodes into it, if you designed your indices to allow that. More on
this later.

<div class="note protip no_toc">
##### Protip!

When growing the cluster, prefer horizontal scaling (adding more nodes) to
vertical scaling (bigger nodes). This will share the load but also allow for better
fault tolerance at the same time.
</div>

## Elasticsearch settings

A few Elasticsearch settings are critical for performance :

* The size of the JVM Heap, which should be half the size of the total amount
of RAM (leaving the other half for OS level disk caching). This is set in the `java.options` file.
* The number of open file handles should be as high as possible (usually a
system setting : for Linux you will find it in the `/etc/security/limits.conf`
configuration file)
* You also should make sure that Elasticsearch data will not be swapped out of
RAM and into disk space to prevent unexpected and sporadic performance drops.

There are quite a few of them, for which Elastic.co provides [ample documentation][es-system-tuning].

<div class="note protip no_toc">
##### Protip!

You will need to tune the OS as well as the JVM so as to squeeze the best
performance out of Elasticsearch.
</div>

## Keeping data tidy

Elasticsearch will require more and more resources (Disk, RAM, CPU) as the
volume of documents grows. Too much data will make Elasticsearch choke on
queries. Therefore it is important to get rid of outdated or obsolete data as
soon as possible.

Deleting documents in an Elasticsearch index is an expensive operation,
especially if there are lots of them. Opposite-wise, dropping an entire index
is cheap.

Therefore, whenever possible, create time-based indexes. For example, each
index will hold data for a specific day, week, month, year etc.
When you want to get rid of old documents, you can easily drop entire
indexes.

As an alternative to deleting indices, you can also close them. This will
retain the data on disk, but will free most of the CPU/RAM resources and also
leave you the option to re-open them if you need them later on.

Finally, there is always data which is stored in indices you can't delete or
close because you still use them regularly. Often the older indices are not
modified anymore : This is typical of time based data, where you will add
documents to the index of the day and the older indices are basically
read-only). Those indices can be optimized to reduce their resource requirements.

To summarize :

* Delete indices when data is obsolete
* Close indices where data might be infrequently accessed
* Optimize indices which are not updated anymore

There is a tool which will help you do this all in bulk : [`curator`][curator].

As an example, here is how you would purge data older than 3 months in our
case :

### Setting the curator YAML configuration files

First you need to create an `actions.yml` YAML configuration file to describe
exactly based on which criteria you want data to be purged :

{% highlight yaml %}
---
# Remember, leave a key empty if there is no value.  None will be a string,
# not a Python "NoneType"
#
# Also remember that all examples have 'disable_action' set to True.  If you
# want to use this action as a template, be sure to set this to False after
# copying it.
actions:
  1:
    action: delete_indices
    description: >-
      Delete indices older than 90 days (based on index name), for bitstamp-
      prefixed indices. Ignore the error if the filter does not result in an
      actionable list of indices (ignore_empty_list) and exit cleanly.
    options:
      ignore_empty_list: True
      timeout_override:
      continue_if_exception: False
      disable_action: True
    filters:
    - filtertype: pattern
      kind: prefix
      value: logstash-
      exclude:
    - filtertype: age
      source: name
      direction: older
      timestring: '%Y-%m-%d'
      unit: days
      unit_count: 90
      exclude:
{% endhighlight %}

<div class="note info">
##### Info

This is directly inspired from the [example provided][curator-example] in the
[official documentation][curator].

Refer to this if you want more information on other possible actions (such as
closing indexes, or reorganizing them through a `forceMerge` action).
</div>

You will also need to create a `config.yml` file which will tell `curator` how
to connect to the Elasticsearch cluster. This is best described in the
[official documentation][curator-config] so I will not cover it here.


### Running the curator command

Once those configuration files created, running `curator` is as simple as :

{% highlight bash %}

curator --config config.yml actions.yml

{% endhighlight %}

This is typically a command you will execute by means of a `cron` job.

You might be interested in the `--dry-run` option : `curator` will tell you
what it would do if it were to run "for real" but not actually perform the
actions. Handy when debugging.


<div class="note protip no_toc">
##### Protip!

This protip is twofold :

* Create "temporal indexes" whenever possible to ease their time based
management / tuning
* Use `curator` to remove all obsolete data, close not-often-used indexes,
optimize read-only indexes

This will lead to a smaller data footprint, and an easier-on-resources
Elasticsearch.
</div>
