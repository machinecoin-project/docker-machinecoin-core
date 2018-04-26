# machinecoin-project/machinecoin-core

A machinecoin-core docker image (originally by @github.com/machinecoin-project).

[![machinecoin-project/machinecoin-core][docker-pulls-image]][docker-hub-url] [![machinecoin-project/machinecoin-core][docker-stars-image]][docker-hub-url] [![machinecoin-project/machinecoin-core][docker-size-image]][docker-hub-url] [![machinecoin-project/machinecoin-core][docker-layers-image]][docker-hub-url]

## Tags

- `0.16.0`, `0.16`, `latest` ([0.16/Dockerfile](https://github.com/machinecoin-project/docker-machinecoin-core/blob/master/0.16/Dockerfile))
- `0.16.0-alpine`, `0.16-alpine` ([0.16/alpine/Dockerfile](https://github.com/machinecoin-project/docker-machinecoin-core/blob/master/0.16/alpine/Dockerfile))

**Picking the right tag**

- `machinecoin-project/docker-machinecoin-core:latest`: points to the latest stable release available of Machinecoin Core. Use this only if you know what you're doing as upgrading Machinecoin Core blindly is a risky procedure.
- `machinecoin-project/docker-machinecoin-core:<version>`: based on a slim Debian image, points to a specific version branch or release of Machinecoin Core. Uses the pre-compiled binaries which are fully tested by the Machinecoin Core team.
- `machinecoin-project/docker-machinecoin-core:<version>-alpine`: based on Alpine Linux with Berkeley DB 4.8 (cross-compatible build), points to a specific version branch or release of Machinecoin Core. Uses a simple, resource efficient Linux distribution with security in mind, but is not officially supported by the Machinecoin Core team. Use at your own risk.

## What is Machinecoin Core?

Machinecoin Core is a reference client that implements the Machinecoin protocol for remote procedure call (RPC) use. It is also the second Machinecoin client in the network's history. Learn more about Machinecoin Core on the [Machinecoin Website](https://machinecoin.io).

## Usage

### How to use this image

This image contains the main binaries from the Machinecoin Core project - `machinecoind`, `machinecoin-cli` and `machinecoin-tx`. It behaves like a binary, so you can pass any arguments to the image and they will be forwarded to the `machinecoind` binary:

```sh
❯ docker run --rm -it machinecoin-project/machinecoin-core \
  -printtoconsole \
  -regtest=1 \
  -rpcallowip=172.17.0.0/16 \
  -rpcauth='foo:7d9ba5ae63c3d4dc30583ff4fe65a67e$9e3634e81c11659e3de036d0bf88f89cd169c1039e6e09607562d54765c649cc'
```

_Note: [learn more](#using-rpcauth-for-remote-authentication) about how `-rpcauth` works for remote authentication._

By default, `machinecoind` will run as user `machinecoin` for security reasons and with its default data dir (`~/.machinecoin`). If you'd like to customize where `machinecoin-core` stores its data, you must use the `MACHINECOIN_DATA` environment variable. The directory will be automatically created with the correct permissions for the `machinecoin` user and `machinecoin-core` automatically configured to use it.

```sh
❯ docker run --env MACHINECOIN_DATA=/var/lib/machinecoin-core --rm -it machinecoin-project/machinecoin-core \
  -printtoconsole \
  -regtest=1
```

You can also mount a directory it in a volume under `/home/machinecoin/.machinecoin` in case you want to access it on the host:

```sh
❯ docker run -v ${PWD}/data:/home/machinecoin/.machinecoin -it --rm machinecoin-project/machinecoin-core \
  -printtoconsole \
  -regtest=1
```

You can optionally create a service using `docker-compose`:

```yml
machinecoin-core:
  image: machinecoin-project/machinecoin-core
  command:
    -printtoconsole
    -regtest=1
```

### Using RPC to interact with the daemon

There are two communications methods to interact with a running Machinecoin Core daemon.

The first one is using a cookie-based local authentication. It doesn't require any special authentication information as running a process locally under the same user that was used to launch the Machinecoin Core daemon allows it to read the cookie file previously generated by the daemon for clients. The downside of this method is that it requires local machine access.

The second option is making a remote procedure call using a username and password combination. This has the advantage of not requiring local machine access, but in order to keep your credentials safe you should use the newer `rpcauth` authentication mechanism.

#### Using cookie-based local authentication

Start by launch the Machinecoin Core daemon:

```sh
❯ docker run --rm --name machinecoin-server -it machinecoin-project/machinecoin-core \
  -printtoconsole \
  -regtest=1
```

Then, inside the running `machinecoin-server` container, locally execute the query to the daemon using `machinecoin-cli`:

```sh
❯ docker exec --user machinecoin machinecoin-server machinecoin-cli -regtest getmininginfo

{
  "blocks": 0,
  "currentblocksize": 0,
  "currentblockweight": 0,
  "currentblocktx": 0,
  "difficulty": 4.656542373906925e-10,
  "errors": "",
  "networkhashps": 0,
  "pooledtx": 0,
  "chain": "regtest"
}
```

In the background, `machinecoin-cli` read the information automatically from `/home/machinecoin/.machinecoin/regtest/.cookie`. In production, the path would not contain the regtest part.

#### Using rpcauth for remote authentication

Before setting up remote authentication, you will need to generate the `rpcauth` line that will hold the credentials for the Machinecoind Core daemon. You can either do this yourself by constructing the line with the format `<user>:<salt>$<hash>` or use the official `rpcauth.py` script to generate this line for you, including a random password that is printed to the console.

Example:

```sh
❯ curl -sSL https://raw.githubusercontent.com/machinecoin/machinecoin/master/share/rpcauth/rpcauth.py | python - <username>

String to be appended to machinecoin.conf:
rpcauth=foo:7d9ba5ae63c3d4dc30583ff4fe65a67e$9e3634e81c11659e3de036d0bf88f89cd169c1039e6e09607562d54765c649cc
Your password:
qDDZdeQ5vw9XXFeVnXT4PZ--tGN2xNjjR4nrtyszZx0=
```

Note that for each run, even if the username remains the same, the output will be always different as a new salt and password are generated.

Now that you have your credentials, you need to start the Machinecoin Core daemon with the `-rpcauth` option. Alternatively, you could append the line to a `machinecoin.conf` file and mount it on the container.

Let's opt for the Docker way:

```sh
❯ docker run --rm --name machinecoin-server -it machinecoin-project/machinecoin-core \
  -printtoconsole \
  -regtest=1 \
  -rpcallowip=172.17.0.0/16 \
  -rpcauth='foo:7d9ba5ae63c3d4dc30583ff4fe65a67e$9e3634e81c11659e3de036d0bf88f89cd169c1039e6e09607562d54765c649cc'
```

Two important notes:

1. Some shells require escaping the rpcauth line (e.g. zsh), as shown above.
2. It is now perfectly fine to pass the rpcauth line as a command line argument. Unlike `-rpcpassword`, the content is hashed so even if the arguments would be exposed, they would not allow the attacker to get the actual password.

You can now connect via `machinecoin-cli` or any other [compatible client](https://github.com/machinecoin-project/machinecoin-core). You will still have to define a username and password when connecting to the Machinecoin Core RPC server.

To avoid any confusion about whether or not a remote call is being made, let's spin up another container to execute `machinecoin-cli` and connect it via the Docker network using the password generated above:

```sh
❯ docker run -it --link machinecoin-server --rm machinecoin-project/machinecoin-core \
  machinecoin-cli \
  -rpcconnect=machinecoin-server \
  -regtest \
  -rpcuser=foo\
  -stdinrpcpass \
  getbalance
```

Enter the password `qDDZdeQ5vw9XXFeVnXT4PZ--tGN2xNjjR4nrtyszZx0=` and hit enter:

```
0.00000000
```

Note: under Machinecoin Core < 0.16, use `-rpcpassword="qDDZdeQ5vw9XXFeVnXT4PZ--tGN2xNjjR4nrtyszZx0="` instead of `-stdinrpcpass`.

Done!

### Exposing Ports

Depending on the network (mode) the Machinecoin Core daemon is running as well as the chosen runtime flags, several default ports may be available for mapping.

Ports can be exposed by mapping all of the available ones (using `-P` and based on what `EXPOSE` documents) or individually by adding `-p`. This mode allows assigning a dynamic port on the host (`-p <port>`) or assigning a fixed port `-p <hostPort>:<containerPort>`.

Example for running a node in `regtest` mode mapping JSON-RPC/REST (18443) and P2P (18444) ports:

```sh
docker run --rm -it \
  -p 18443:18443 \
  -p 18444:18444 \
  machinecoin-project/machinecoin-core \
  -printtoconsole \
  -regtest=1 \
  -rpcallowip=172.17.0.0/16 \
  -rpcauth='foo:7d9ba5ae63c3d4dc30583ff4fe65a67e$9e3634e81c11659e3de036d0bf88f89cd169c1039e6e09607562d54765c649cc'
```

To test that mapping worked, you can send a JSON-RPC curl request to the host port:

```
curl --data-binary '{"jsonrpc":"1.0","id":"1","method":"getnetworkinfo","params":[]}' http://foo:qDDZdeQ5vw9XXFeVnXT4PZ--tGN2xNjjR4nrtyszZx0=@127.0.0.1:18443/
```

#### Mainnet

- JSON-RPC/REST: 40332
- P2P: 40333

#### Testnet

- Testnet JSON-RPC: 50332
- P2P: 50333

#### Regtest

- JSON-RPC/REST: 60332
- P2P: 60333

## Archived tags

For historical reasons, the following tags are still available and automatically updated when the underlying base image (_Alpine Linux_ or _Debian stable_) is updated as well:

- `0.16.0`, `0.16` ([0.16/Dockerfile](https://github.com/machinecoin-project/docker-machinecoin-core/blob/master/0.16/Dockerfile))
- `0.16.0-alpine`, `0.16-alpine` ([0.16/alpine/Dockerfile](https://github.com/machinecoin-project/docker-machinecoin-core/blob/master/0.16/alpine/Dockerfile))

## Docker

This image is officially supported on Docker version 17.09, with support for older versions provided on a best-effort basis.

## License

[License information](https://github.com/machinecoin/machinecoin/blob/master/COPYING) for the software contained in this image.

[License information](https://github.com/machinecoin-project/docker-machinecoin-core/blob/master/LICENSE) for the [machinecoin-project/docker-machinecoin-core][docker-hub-url] docker project.

[docker-hub-url]: https://hub.docker.com/r/machinecoin-project/machinecoin-core
[docker-layers-image]: https://img.shields.io/imagelayers/layers/machinecoin-project/machinecoin-core/latest.svg?style=flat-square
[docker-pulls-image]: https://img.shields.io/docker/pulls/machinecoin-project/machinecoin-core.svg?style=flat-square
[docker-size-image]: https://img.shields.io/imagelayers/image-size/machinecoin-project/machinecoin-core/latest.svg?style=flat-square
[docker-stars-image]: https://img.shields.io/docker/stars/machinecoin-project/machinecoin-core.svg?style=flat-square
