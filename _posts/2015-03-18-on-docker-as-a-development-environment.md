---
layout: post
title: "On docker as a development environment"
tags:
 -
---

A few weeks ago I got a new laptop, and, even though I've been doing quite
a bit of development work with it, I haven't bothered to install either
virtualenv, rvm, bundler or any other dev management tool... Besides
[Docker](https://www.docker.com/) and
[Compose](http://docs.docker.com/compose/)

Compose (formerly known as Fig) is a layer on top of Docker that, in a very
simple way, allows for both runtime configuration of containers and linking
between them. Runtime configuration is the kind of stuff you may pass in the
command line to a Docker image when running it: port forwardings, volume
mounting, entrypoints... Linking of containers allows them to see each other
without the need to expose any ports. And all this is done using a really
simple YAML configuration file that you can check into your repository to make
the whole environment replicable.

So, if you have a Ruby web app that uses MongoDB for persistence and Memcache
as a caching service, instead of installing every single dependency on your
dev machine, you may just create a Dockerfile for the app, and then create
a Compose configuration that mounts the source of the app as a volume (so that
changes you make in your code are immediately available on the container),
sets up the port forwaring so you can see the app from your browser and that
links it with containers for Memcache and Mongodb. You probably won't even
need to do anything special with these two since they are already built on the
[Docker Hub](https://registry.hub.docker.com/). Then just by doing
`docker-compose up` you'll have your whole environment up and ready to use.
Make sure to check [Compose's
quickstart](http://docs.docker.com/compose/#quick-start) for an example of all
this in action.

Impressive as this is (and it is, not only in what it does but in how easy and
painless the whole process is) it isn't enough for a development machine.  The
first issue I encountered was doing stuff inside the container besides the
entrypoint declared on the Dockerfile, like running a REPL, a debugger or a db
console.  Compose's default way of doing this is through `docker-compose run
SERVICE COMMAND`, which will start a new container for the same image and run
`COMMAND`. This is not that great, since it takes a while for the container to
start (a simple echo for the container I use for this blog takes about 1.5
seconds). Docker already has exec, which runs the command on the same
container (the same test using docker exec takes 0.33 seconds). If
I understand correctly there's already work to integrate it into Compose, so
this hopefully won't be an issue for much longer, in the meantime I've been
playing around with an idea to tie commands to containers that can be then run
using `docker exec` in [Fede](https://github.com/dgsuarez/fede) (keep in mind
this is extremely alpha software)

The next problem I found is a permissions one. Even though I use Docker as
a non-root user, files created in mounted volumes inside the container are
created as root (since I just use root as the user for the container), so
checking logs or uploaded files sometimes means chmodding them. Luckily this
was [solved a couple of weeks
ago](https://github.com/docker/docker/issues/3124) in Docker, so it should be
included in Docker's next release.

And finally, the last issue I've been having is long build times when using
external package managers like bundler or pip. Since Docker's cache is per
command, adding a new dependency to your requirements.txt means that when
rebuilding the image, once it gets to `RUN pip install requirements.txt` it
won't have any package cached, so if you have enough packages this will take
a long time. In one project where I was using scipy, it got to be so bad that
I just had to add a `RUN pip install scipy` before the requirements line so
that at least this package was cached. While [I'm not the first one to notice
it](https://muffinresearch.co.uk/docker-and-dependencies/), I haven't yet seen
any good solution to this problem. I'd like to explore the possibility of
having this kind of tools emit a series of Docker commands that could be run
sequentially and that Docker could cache (a kind of Docker meta command), so
`pip install requirements.txt --docker` would return a series of `RUN pip
install <package>` that Docker could then run and cache independently for
future builds.

All things considered, I'm quite happy with using Docker for the kind of hobby
stuff I do at home. The UX can certainly be improved, but being able to tap
into Docker's hub for all kinds of services and base images for tons of
programming languages, that I can link together and bring up and down with
a single command, without any discernible performance penalty is just so great
that I'm willing to put up with it while the kinks are ironed out, which in my
experience with Docker will probably be pretty soon.
