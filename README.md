## Development server

A collection of Chef recipes and a Vagrantfile, intended for the creation of a VirtualBox development server running all the services one would need.

### Chef recipes

You'll find a collection of recipes here, none of which is originally "mine". I'll list the credits and links to the originals here:

* [java](https://github.com/opscode-cookbooks/java), submodule pointing to release 1.8.0

The Chef recipes are only tested in chef-solo mode.

### Vagrantfile

Simple really: it contains chef dna for solo run, as well as networking setup for the server. By default, it points to a box named 'precise64', which can be found at the [Vagrantup site](http://files.vagrantup.com/precise64.box).

64 bit box as the Riak release is not available for the 32 bit ubuntu as a deb file.