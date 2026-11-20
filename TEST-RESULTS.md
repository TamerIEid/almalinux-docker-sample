# VM to Docker test

On 20 November 2026, a disposable AlmaLinux 9.9 x86_64 VM ran the stock service under systemd with SELinux enforcing. Both the Python file and the unit on the VM matched their copies in this repository.

The fixture in Git contains 17 cables. The running VM held 19. The test copied the live response into a fresh Docker volume and checked the result through HTTP. Seeing 19 in the container distinguishes migrated data from the fixture in Git.

| Check | Observed result |
| --- | --- |
| VM service status | active |
| VM stock | 19 cables and 6 plugs |
| First container | HTTP 200, stock matched the VM byte for byte |
| Replacement container, same volume | HTTP 200, stock matched the VM byte for byte |
| Container process identity | UID 10001 |

The VM response and both container responses had this SHA-256:

```text
1f37a943e8af30dd1d307c450a3c6c00b76d187ad5bf6a6a0a03ef06bfa1f356
```

An independent run using the saved 17-cable fixture also passed. Its response hash was:

```text
cf4c802fb66e41897474868c680d0d97013cb2f47c53e189e0a1161c7efeeba2
```

The source VM used the official AlmaLinux GenericCloud 9.9 image dated 2026-11-16. Its downloaded file matched the published SHA-256. The destination used Docker Engine 28.1.1 and the AlmaLinux digest in the Dockerfile.

This was a synthetic service with a single data file. Codex assisted with the sample and ran the checks. No client VM or client data was used.
