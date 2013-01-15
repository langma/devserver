# Development server

A collection of Chef recipes and a Vagrantfile, intended for the creation of a VirtualBox development server running all the services one would need in a "backend"
 server.

## Usage

* Install [VirtualBox](https://www.virtualbox.org/)
* Install [Vagrant](http://www.vagrantup.com/)
* Clone this repo and init submodules (`git submodule update --init`)
* Start a server: run `vagrant up` at repo's root. This will fetch the default server image defined in `Vagrantfile`, start it and provision the services defined it in the file. The default image is Ubuntu 12.04 (Precise) 64-bit. For more server images ("boxes"), see [http://www.vagrantbox.es/].

Done! you should be able to access the running server with `vagrant ssh`. The default IP address of the server is 10.10.10.10, accessible only from the host, so you can see the services installed there.

## Details

### Chef recipes

You'll find a collection of recipes here, none of which is originally "mine". I'll list the credits and links to the originals here.

#### Opscode recipes

I have linked the [Opscode](http://www.opscode.com/) recipes as git submodules where possible:

* [java](https://github.com/opscode-cookbooks/java), Vagrantfile configures java7 from Oracle by default
* [runit](https://github.com/opscode-cookbooks/runit), no configuration needed
* [memcached](https://github.com/opscode-cookbooks/memcached), no configuration needed

  Test memcached in the server: `telnet localhost 11211` and then `stats`. Quit by saying `quit`. For more info, see for example [http://lzone.de/articles/memcached.htm].

#### Customised recipes

* Apache Kafka, redid this according to [librato's recipe](https://github.com/librato/kafka-cookbook) and [Webtrend's recipe](http://community.opscode.com/cookbooks/kafka). Did not fork as they are much more confgurable (and complex), I just wanted Kafka & Zookeeper to work
* Riak, fork of the [Opscode hosted recipe](http://community.opscode.com/cookbooks/riak). Modified so that the listen address is 0.0.0.0 (all interfaces). Without this modification Riak would listen to eth0 by default, whereas vagrant adds eth1 as the defined interface. I did not manage to set this with chef-solo json configuration, so it's hard-coded now.

  [Test Riak after installation](http://10.10.10.10:8098/buckets?buckets=true), you should see empty buckets..

The Chef recipes are tested by me only in chef-solo mode with vagrant.

### Vagrantfile

Simple really: it contains chef dna json for a chef-solo run, as well as networking setup for the server. By default, it points to a box named 'precise64', which can be found at the [Vagrantup site](http://files.vagrantup.com/precise64.box).

It also contains a run list, which is used when provisioning the software with chef. Edit the run list to add/remove services that are deployed in the server.

We must use a 64 bit box as the Riak release is not available for the 32 bit Precise as a [deb file](http://basho.com/resources/downloads/).