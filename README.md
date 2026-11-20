# Move an AlmaLinux service into Docker

This sample moves a small warehouse stock service from an AlmaLinux 9 VM into an AlmaLinux 9 container. A request to `/stock` reads a JSON file from disk. The service, stock counts and VM were created for this demonstration.

On the VM, systemd starts the Python process. In Docker, the image starts the same program directly as UID 10001. A named volume holds the stock data. This lets you replace the container or rebuild the image without including customer data in the build.

## Try it

On Linux with Docker, Bash, curl and Python 3 installed, run:

```sh
./verify.sh
```

The script builds the image, loads the sample stock into a new volume, starts a container and compares its HTTP response with the source file. It then removes that container, starts another on the same volume and checks the response again. It binds only to localhost and cleans up the test containers and volume. The built image remains as `almalinux-inventory-sample:local`.

To take the stock from a running copy of the sample VM service, pass its local URL instead:

```sh
./verify.sh http://127.0.0.1:38618/stock
```

In this service the HTTP response is the entire stock file. For an application backed by a database, use its supported backup and restore tools and test a representative transaction.

## Source VM

The [systemd unit](vm/inventory.service) shows the original startup command. On a fresh disposable AlmaLinux 9 VM with Python 3 installed, run these commands from a copy of this repository:

```sh
sudo install -d -m 0755 /opt/inventory /var/lib/inventory
sudo install -D -m 0644 inventory.py /opt/inventory/inventory.py
sudo install -D -m 0644 vm/stock.json /var/lib/inventory/stock.json
sudo install -m 0644 vm/inventory.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now inventory.service
curl -fsS http://127.0.0.1:8080/stock
```

When running Docker on a separate machine, use an SSH tunnel to reach the VM's local port or run both checks from a trusted test network. The stock endpoint is intended for local testing.

## Files to review

- [Dockerfile](Dockerfile) pins the AlmaLinux base by digest and copies just the application.
- [Inventory service](inventory.py) reads the stock file for each request.
- [Verification script](verify.sh) transfers the sample data and checks both containers.
- [Recorded test](TEST-RESULTS.md) lists the VM version, source data and observed response hashes.
